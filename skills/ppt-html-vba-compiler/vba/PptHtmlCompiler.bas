Attribute VB_Name = "PptHtmlCompiler"
Option Explicit

' PPT-HTML VBA Compiler v0.1.0
' Fixed deterministic engine for schema major version 1.

Private Const COMPILER_VERSION As String = "0.1.0"
Private Const PP_LAYOUT_BLANK As Long = 12
Private Const PP_SAVE_AS_PPTX As Long = 24
Private Const MSO_FALSE As Long = 0
Private Const MSO_TRUE As Long = -1
Private Const MSO_TEXT_HORIZONTAL As Long = 1
Private Const MSO_BRING_TO_FRONT As Long = 0

Public Sub CompilePptHtmlFile(ByVal HtmlPath As String, ByVal OutputPath As String, Optional ByVal ReportPath As String = "")
    Dim model As Dictionary
    Dim report As Dictionary
    Dim inventory As Collection
    Dim warnings As Collection
    Dim errors As Collection
    Dim pres As Presentation
    Dim slidesDef As Collection
    Dim slideDef As Variant
    Dim sld As Slide
    Dim shapeNames As Dictionary
    Dim htmlText As String
    Dim modelJson As String
    Dim inventoryPath As String
    Dim slideCount As Long
    Dim objectCount As Long

    On Error GoTo CompileFailed

    If Len(ReportPath) = 0 Then ReportPath = ChangeExtension(OutputPath, ".compile-report.json")
    inventoryPath = ChangeExtension(OutputPath, ".object-inventory.json")

    Set report = New Dictionary
    Set inventory = New Collection
    Set warnings = New Collection
    Set errors = New Collection
    report.Add "compilerVersion", COMPILER_VERSION
    report.Add "status", "running"
    report.Add "sourceHtml", HtmlPath
    report.Add "outputPptx", OutputPath
    report.Add "objectInventory", inventoryPath
    report.Add "warnings", warnings
    report.Add "errors", errors

    RequireAbsolutePath HtmlPath, "HtmlPath"
    RequireAbsolutePath OutputPath, "OutputPath"
    RequireAbsolutePath ReportPath, "ReportPath"
    If Not FileExists(HtmlPath) Then Err.Raise vbObjectError + 2000, , "HTML file not found: " & HtmlPath

    htmlText = ReadUtf8File(HtmlPath)
    modelJson = ExtractModelJson(htmlText)
    Set model = JsonConverter.ParseJson(modelJson)
    ValidateRootModel model
    If VersionLessThan(COMPILER_VERSION, CStr(model("minimumCompilerVersion"))) Then
        Err.Raise vbObjectError + 2047, , "Compiler " & COMPILER_VERSION & " is older than required " & CStr(model("minimumCompilerVersion"))
    End If

    report.Add "schemaVersion", CStr(model("schemaVersion"))
    report.Add "standardVersion", CStr(model("standardVersion"))
    report.Add "minimumCompilerVersion", CStr(model("minimumCompilerVersion"))

    Set pres = Application.Presentations.Add(MSO_TRUE)
    Do While pres.Slides.Count > 0
        pres.Slides(1).Delete
    Loop
    pres.PageSetup.SlideWidth = 960
    pres.PageSetup.SlideHeight = 540

    Set slidesDef = model("slides")
    For Each slideDef In slidesDef
        ValidateSlide slideDef
        Set sld = pres.Slides.Add(pres.Slides.Count + 1, PP_LAYOUT_BLANK)
        sld.Name = SafeName(CStr(slideDef("id")))
        If slideDef.Exists("background") Then
            sld.FollowMasterBackground = MSO_FALSE
            ApplyFillFormat sld.Background.Fill, slideDef("background"), warnings
        End If

        Set shapeNames = New Dictionary
        CompileSlideObjects sld, slideDef, shapeNames, inventory, warnings, HtmlPath, CStr(model("schemaVersion")), objectCount
        slideCount = slideCount + 1
    Next slideDef

    pres.SaveAs OutputPath, PP_SAVE_AS_PPTX
    pres.Close
    Set pres = Nothing

    report("status") = "success"
    report.Add "slideCount", slideCount
    report.Add "objectCount", objectCount
    WriteUtf8File inventoryPath, JsonConverter.ConvertToJson(inventory, 2)
    WriteUtf8File ReportPath, JsonConverter.ConvertToJson(report, 2)
    Exit Sub

CompileFailed:
    On Error Resume Next
    If errors Is Nothing Then Set errors = New Collection
    errors.Add "Error " & CStr(Err.Number) & ": " & Err.Description
    If report Is Nothing Then Set report = New Dictionary
    If Not report.Exists("compilerVersion") Then report.Add "compilerVersion", COMPILER_VERSION
    If report.Exists("status") Then
        report("status") = "failed"
    Else
        report.Add "status", "failed"
    End If
    If Not report.Exists("errors") Then report.Add "errors", errors
    If Not pres Is Nothing Then pres.Close
    If Len(ReportPath) > 0 Then WriteUtf8File ReportPath, JsonConverter.ConvertToJson(report, 2)
    Dim failureMessage As String
    failureMessage = errors(errors.Count)
    On Error GoTo 0
    Err.Raise vbObjectError + 2099, "PptHtmlCompiler", failureMessage
End Sub

Private Sub CompileSlideObjects(ByVal sld As Slide, ByVal slideDef As Dictionary, ByVal shapeNames As Dictionary, _
                                ByVal inventory As Collection, ByVal warnings As Collection, ByVal htmlPath As String, _
                                ByVal schemaVersion As String, ByRef objectCount As Long)
    Dim objectsDef As Collection
    Dim ordered As Collection
    Dim obj As Variant
    Dim shp As Shape
    Dim objectType As String

    Set objectsDef = slideDef("objects")
    Set ordered = SortObjects(objectsDef)

    For Each obj In ordered
        objectType = LCase$(CStr(obj("type")))
        If objectType <> "group" Then
            Set shp = CreateObjectShape(sld, obj, warnings, htmlPath)
            FinalizeShape sld, shp, obj, schemaVersion
            shapeNames.Add CStr(obj("id")), shp.Name
            AddInventory inventory, CStr(slideDef("id")), obj, shp
            objectCount = objectCount + 1
        End If
    Next obj

    For Each obj In ordered
        objectType = LCase$(CStr(obj("type")))
        If objectType = "group" Then
            Set shp = CreateGroupShape(sld, obj, shapeNames)
            FinalizeShape sld, shp, obj, schemaVersion
            shapeNames.Add CStr(obj("id")), shp.Name
            AddInventory inventory, CStr(slideDef("id")), obj, shp
            objectCount = objectCount + 1
        End If
    Next obj

    For Each obj In ordered
        If shapeNames.Exists(CStr(obj("id"))) Then
            BringNamedShapeToFront sld, CStr(shapeNames(CStr(obj("id"))))
        End If
    Next obj
End Sub

Private Sub BringNamedShapeToFront(ByVal sld As Slide, ByVal shapeName As String)
    Dim shp As Shape
    On Error Resume Next
    Set shp = sld.Shapes(shapeName)
    On Error GoTo 0
    ' A grouped child is no longer a top-level slide shape; its group controls z-order.
    If Not shp Is Nothing Then shp.ZOrder MSO_BRING_TO_FRONT
End Sub

Private Function CreateObjectShape(ByVal sld As Slide, ByVal obj As Dictionary, ByVal warnings As Collection, ByVal htmlPath As String) As Shape
    Dim objectType As String
    Dim bounds As Dictionary
    Dim x As Single, y As Single, w As Single, h As Single
    Dim shp As Shape

    objectType = LCase$(CStr(obj("type")))
    Set bounds = obj("bounds")
    x = CSng(bounds("x")): y = CSng(bounds("y"))
    w = CSng(bounds("w")): h = CSng(bounds("h"))

    Select Case objectType
        Case "shape"
            Set shp = sld.Shapes.AddShape(MapShapeType(GetString(obj, "shapeType", "rect")), x, y, w, h)
            ApplyShapeStyle shp, obj, warnings
            If obj.Exists("text") Then ApplyText shp, CStr(obj("text")), obj
        Case "text"
            Set shp = sld.Shapes.AddTextbox(MSO_TEXT_HORIZONTAL, x, y, w, h)
            ApplyText shp, GetString(obj, "text", ""), obj
        Case "image", "svg"
            Set shp = sld.Shapes.AddPicture(ResolveAssetPath(htmlPath, CStr(obj("asset"))), MSO_FALSE, MSO_TRUE, x, y, w, h)
        Case "line"
            Set shp = sld.Shapes.AddLine(x, y, x + w, y + h)
            If obj.Exists("line") Then ApplyLineFormat shp.Line, obj("line")
        Case "connector"
            Set shp = sld.Shapes.AddConnector(1, x, y, x + w, y + h)
            If obj.Exists("line") Then ApplyLineFormat shp.Line, obj("line")
        Case "table"
            Set shp = CreateTableShape(sld, obj, x, y, w, h)
        Case "chart"
            Set shp = CreateChartShape(sld, obj, x, y, w, h, warnings)
        Case Else
            Err.Raise vbObjectError + 2010, , "Unsupported object type: " & objectType
    End Select

    Set CreateObjectShape = shp
End Function

Private Function CreateGroupShape(ByVal sld As Slide, ByVal obj As Dictionary, ByVal shapeNames As Dictionary) As Shape
    Dim children As Collection
    Dim names() As Variant
    Dim i As Long
    Dim childId As String
    Dim grouped As Shape
    Dim bounds As Dictionary

    Set children = obj("children")
    If children.Count < 2 Then Err.Raise vbObjectError + 2011, , "Group requires at least two children"
    ReDim names(1 To children.Count)
    For i = 1 To children.Count
        childId = CStr(children(i))
        If Not shapeNames.Exists(childId) Then Err.Raise vbObjectError + 2012, , "Group child not found: " & childId
        names(i) = CStr(shapeNames(childId))
    Next i
    Set grouped = sld.Shapes.Range(names).Group
    Set bounds = obj("bounds")
    grouped.Left = CSng(bounds("x"))
    grouped.Top = CSng(bounds("y"))
    grouped.Width = CSng(bounds("w"))
    grouped.Height = CSng(bounds("h"))
    Set CreateGroupShape = grouped
End Function

Private Function CreateTableShape(ByVal sld As Slide, ByVal obj As Dictionary, ByVal x As Single, ByVal y As Single, ByVal w As Single, ByVal h As Single) As Shape
    Dim tableDef As Dictionary
    Dim rows As Collection
    Dim rowDef As Variant
    Dim rowCount As Long, columnCount As Long
    Dim r As Long, c As Long
    Dim shp As Shape

    Set tableDef = obj("table")
    Set rows = tableDef("rows")
    rowCount = rows.Count
    For Each rowDef In rows
        If rowDef.Count > columnCount Then columnCount = rowDef.Count
    Next rowDef
    If rowCount = 0 Or columnCount = 0 Then Err.Raise vbObjectError + 2020, , "Table rows cannot be empty"

    Set shp = sld.Shapes.AddTable(rowCount, columnCount, x, y, w, h)
    For r = 1 To rowCount
        Set rowDef = rows(r)
        For c = 1 To columnCount
            If c <= rowDef.Count Then
                shp.Table.Cell(r, c).Shape.TextFrame2.TextRange.Text = CStr(rowDef(c))
            Else
                shp.Table.Cell(r, c).Shape.TextFrame2.TextRange.Text = ""
            End If
        Next c
    Next r
    Set CreateTableShape = shp
End Function

Private Function CreateChartShape(ByVal sld As Slide, ByVal obj As Dictionary, ByVal x As Single, ByVal y As Single, ByVal w As Single, ByVal h As Single, ByVal warnings As Collection) As Shape
    Dim chartDef As Dictionary
    Dim categories As Collection
    Dim seriesDef As Collection
    Dim oneSeries As Variant
    Dim values As Collection
    Dim shp As Shape
    Dim chartObject As Object
    Dim workbook As Object
    Dim sheet As Object
    Dim r As Long, c As Long
    Dim chartType As Long

    Set chartDef = obj("chart")
    Set categories = chartDef("categories")
    Set seriesDef = chartDef("series")
    chartType = MapChartType(GetString(chartDef, "kind", "column-clustered"))
    Set shp = sld.Shapes.AddChart2(-1, chartType, x, y, w, h)
    Set chartObject = shp.Chart
    chartObject.ChartData.Activate
    Set workbook = chartObject.ChartData.Workbook
    Set sheet = workbook.Worksheets(1)
    sheet.Cells.Clear

    For r = 1 To categories.Count
        sheet.Cells(r + 1, 1).Value = categories(r)
    Next r
    For c = 1 To seriesDef.Count
        Set oneSeries = seriesDef(c)
        sheet.Cells(1, c + 1).Value = GetString(oneSeries, "name", "Series " & CStr(c))
        Set values = oneSeries("values")
        If values.Count <> categories.Count Then Err.Raise vbObjectError + 2030, , "Chart series length differs from categories"
        For r = 1 To values.Count
            sheet.Cells(r + 1, c + 1).Value = values(r)
        Next r
    Next c
    chartObject.SetSourceData sheet.Range(sheet.Cells(1, 1), sheet.Cells(categories.Count + 1, seriesDef.Count + 1))
    If chartDef.Exists("title") Then
        chartObject.HasTitle = True
        chartObject.ChartTitle.Text = CStr(chartDef("title"))
    End If
    On Error Resume Next
    workbook.Close True
    If Err.Number <> 0 Then
        warnings.Add "Chart workbook remained open for object " & CStr(obj("id"))
        Err.Clear
    End If
    On Error GoTo 0
    Set CreateChartShape = shp
End Function

Private Sub ApplyShapeStyle(ByVal shp As Shape, ByVal obj As Dictionary, ByVal warnings As Collection)
    If obj.Exists("fill") Then ApplyFillFormat shp.Fill, obj("fill"), warnings
    If obj.Exists("line") Then ApplyLineFormat shp.Line, obj("line")
    If obj.Exists("effects") Then ApplyEffects shp, obj("effects"), warnings
End Sub

Private Sub ApplyFillFormat(ByVal fill As FillFormat, ByVal fillDef As Dictionary, ByVal warnings As Collection)
    Dim kind As String
    kind = LCase$(GetString(fillDef, "kind", "none"))
    Select Case kind
        Case "none"
            fill.Visible = MSO_FALSE
        Case "solid"
            fill.Visible = MSO_TRUE
            fill.Solid
            fill.ForeColor.RGB = HexToRgb(GetString(fillDef, "color", "#FFFFFF"))
            fill.Transparency = CSng(GetNumber(fillDef, "transparency", 0))
        Case "linear-gradient"
            fill.Visible = MSO_TRUE
            fill.ForeColor.RGB = HexToRgb(GetString(fillDef, "color", "#FFFFFF"))
            fill.BackColor.RGB = HexToRgb(GetString(fillDef, "color2", "#000000"))
            fill.TwoColorGradient 1, 1
            On Error Resume Next
            fill.GradientAngle = CSng(GetNumber(fillDef, "angle", 0))
            On Error GoTo 0
        Case Else
            warnings.Add "Unsupported fill kind used as no fill: " & kind
            fill.Visible = MSO_FALSE
    End Select
End Sub

Private Sub ApplyLineFormat(ByVal line As LineFormat, ByVal lineDef As Dictionary)
    If Not GetBoolean(lineDef, "visible", True) Then
        line.Visible = MSO_FALSE
        Exit Sub
    End If
    line.Visible = MSO_TRUE
    If lineDef.Exists("color") Then line.ForeColor.RGB = HexToRgb(CStr(lineDef("color")))
    If lineDef.Exists("width") Then line.Weight = CSng(lineDef("width"))
    If lineDef.Exists("transparency") Then line.Transparency = CSng(lineDef("transparency"))
    If lineDef.Exists("dash") Then line.DashStyle = MapDashStyle(CStr(lineDef("dash")))
End Sub

Private Sub ApplyText(ByVal shp As Shape, ByVal value As String, ByVal obj As Dictionary)
    Dim textStyle As Dictionary
    Dim fontDef As Dictionary
    Dim textFrame As TextFrame2
    Dim textRange As TextRange2

    Set textFrame = shp.TextFrame2
    Set textRange = textFrame.TextRange
    textRange.Text = value
    If Not obj.Exists("textStyle") Then Exit Sub
    Set textStyle = obj("textStyle")

    textFrame.MarginLeft = CSng(GetNumber(textStyle, "marginLeft", 0))
    textFrame.MarginRight = CSng(GetNumber(textStyle, "marginRight", 0))
    textFrame.MarginTop = CSng(GetNumber(textStyle, "marginTop", 0))
    textFrame.MarginBottom = CSng(GetNumber(textStyle, "marginBottom", 0))
    textFrame.WordWrap = IIf(GetBoolean(textStyle, "wrap", True), MSO_TRUE, MSO_FALSE)
    textFrame.AutoSize = MapAutoSize(GetString(textStyle, "autoSize", "none"))
    textFrame.VerticalAnchor = MapVerticalAnchor(GetString(textStyle, "verticalAlign", "top"))
    textRange.ParagraphFormat.Alignment = MapTextAlignment(GetString(textStyle, "align", "left"))

    If textStyle.Exists("font") Then
        Set fontDef = textStyle("font")
        textRange.Font.Name = GetString(fontDef, "family", "Aptos")
        textRange.Font.Size = CSng(GetNumber(fontDef, "size", 18))
        If fontDef.Exists("color") Then textRange.Font.Fill.ForeColor.RGB = HexToRgb(CStr(fontDef("color")))
        textRange.Font.Bold = IIf(GetBoolean(fontDef, "bold", False), MSO_TRUE, MSO_FALSE)
        textRange.Font.Italic = IIf(GetBoolean(fontDef, "italic", False), MSO_TRUE, MSO_FALSE)
        If fontDef.Exists("tracking") Then textRange.Font.Spacing = CSng(fontDef("tracking"))
    End If
End Sub

Private Sub ApplyEffects(ByVal shp As Shape, ByVal effectsDef As Dictionary, ByVal warnings As Collection)
    Dim shadowDef As Dictionary
    Dim glowDef As Dictionary
    If effectsDef.Exists("shadow") Then
        Set shadowDef = effectsDef("shadow")
        shp.Shadow.Visible = MSO_TRUE
        shp.Shadow.ForeColor.RGB = HexToRgb(GetString(shadowDef, "color", "#000000"))
        shp.Shadow.Transparency = CSng(GetNumber(shadowDef, "transparency", 0.5))
        shp.Shadow.Blur = CSng(GetNumber(shadowDef, "blur", 6))
        shp.Shadow.OffsetX = CSng(GetNumber(shadowDef, "offsetX", 2))
        shp.Shadow.OffsetY = CSng(GetNumber(shadowDef, "offsetY", 2))
    End If
    If effectsDef.Exists("glow") Then
        Set glowDef = effectsDef("glow")
        On Error Resume Next
        shp.Glow.Color.RGB = HexToRgb(GetString(glowDef, "color", "#FFFFFF"))
        shp.Glow.Radius = CSng(GetNumber(glowDef, "radius", 4))
        shp.Glow.Transparency = CSng(GetNumber(glowDef, "transparency", 0.25))
        If Err.Number <> 0 Then
            warnings.Add "Glow could not be applied to " & CStr(shp.Name)
            Err.Clear
        End If
        On Error GoTo 0
    End If
End Sub

Private Sub FinalizeShape(ByVal sld As Slide, ByVal shp As Shape, ByVal obj As Dictionary, ByVal schemaVersion As String)
    shp.Name = UniqueShapeName(sld, "ppt_" & SafeName(CStr(obj("id"))), shp.Id)
    If obj.Exists("rotation") Then shp.Rotation = CSng(obj("rotation"))
    shp.Tags.Add "ppt-html-id", CStr(obj("id"))
    shp.Tags.Add "ppt-html-type", CStr(obj("type"))
    shp.Tags.Add "ppt-html-schema", schemaVersion
    shp.Tags.Add "ppt-html-fidelity", CStr(obj("fidelity"))
    If obj.Exists("altText") Then shp.AlternativeText = CStr(obj("altText"))
End Sub

Private Sub AddInventory(ByVal inventory As Collection, ByVal slideId As String, ByVal obj As Dictionary, ByVal shp As Shape)
    Dim item As Dictionary
    Set item = New Dictionary
    item.Add "slideId", slideId
    item.Add "objectId", CStr(obj("id"))
    item.Add "expectedType", CStr(obj("type"))
    item.Add "powerPointShapeType", CLng(shp.Type)
    item.Add "shapeName", shp.Name
    item.Add "left", CDbl(shp.Left)
    item.Add "top", CDbl(shp.Top)
    item.Add "width", CDbl(shp.Width)
    item.Add "height", CDbl(shp.Height)
    item.Add "rotation", CDbl(shp.Rotation)
    item.Add "fidelity", CStr(obj("fidelity"))
    item.Add "editable", True
    inventory.Add item
End Sub

Private Sub ValidateRootModel(ByVal model As Dictionary)
    Dim schemaVersion As String
    Dim schemaParts() As String
    If Not model.Exists("schemaVersion") Then Err.Raise vbObjectError + 2040, , "schemaVersion is required"
    schemaVersion = CStr(model("schemaVersion"))
    schemaParts = Split(schemaVersion, ".")
    If schemaParts(0) <> "1" Then Err.Raise vbObjectError + 2041, , "Unsupported schema major: " & schemaVersion
    If Not model.Exists("standardVersion") Then Err.Raise vbObjectError + 2042, , "standardVersion is required"
    If Not model.Exists("minimumCompilerVersion") Then Err.Raise vbObjectError + 2043, , "minimumCompilerVersion is required"
    If Not model.Exists("slideSize") Then Err.Raise vbObjectError + 2044, , "slideSize is required"
    If CDbl(model("slideSize")("width")) <> 960 Or CDbl(model("slideSize")("height")) <> 540 Then
        Err.Raise vbObjectError + 2045, , "Only 960 x 540 slideSize is supported"
    End If
    If Not model.Exists("slides") Then Err.Raise vbObjectError + 2046, , "slides are required"
End Sub

Private Sub ValidateSlide(ByVal slideDef As Dictionary)
    If Not slideDef.Exists("id") Then Err.Raise vbObjectError + 2050, , "Slide ID is required"
    If Not slideDef.Exists("objects") Then Err.Raise vbObjectError + 2051, , "Slide objects are required"
End Sub

Private Function SortObjects(ByVal objectsDef As Collection) As Collection
    Dim result As New Collection
    Dim obj As Variant
    Dim i As Long
    Dim inserted As Boolean
    For Each obj In objectsDef
        inserted = False
        For i = 1 To result.Count
            If SortKey(obj) < SortKey(result(i)) Then
                result.Add obj, Before:=i
                inserted = True
                Exit For
            End If
        Next i
        If Not inserted Then result.Add obj
    Next obj
    Set SortObjects = result
End Function

Private Function SortKey(ByVal obj As Dictionary) As Double
    SortKey = CDbl(obj("z"))
End Function

Private Function VersionLessThan(ByVal actualVersion As String, ByVal requiredVersion As String) As Boolean
    Dim actualParts() As String, requiredParts() As String
    Dim i As Long, actualValue As Long, requiredValue As Long
    actualParts = Split(actualVersion, ".")
    requiredParts = Split(requiredVersion, ".")
    For i = 0 To 2
        actualValue = 0: requiredValue = 0
        If i <= UBound(actualParts) Then actualValue = CLng(Val(actualParts(i)))
        If i <= UBound(requiredParts) Then requiredValue = CLng(Val(requiredParts(i)))
        If actualValue < requiredValue Then VersionLessThan = True: Exit Function
        If actualValue > requiredValue Then Exit Function
    Next i
End Function

Private Function ExtractModelJson(ByVal htmlText As String) As String
    Dim idPos As Long, openEnd As Long, closePos As Long
    idPos = InStr(1, htmlText, "ppt-model", vbTextCompare)
    If idPos = 0 Then Err.Raise vbObjectError + 2060, , "Missing script#ppt-model"
    openEnd = InStr(idPos, htmlText, ">", vbBinaryCompare)
    If openEnd = 0 Then Err.Raise vbObjectError + 2061, , "Malformed ppt-model script tag"
    closePos = InStr(openEnd + 1, htmlText, "</script>", vbTextCompare)
    If closePos = 0 Then Err.Raise vbObjectError + 2062, , "Missing ppt-model closing script tag"
    ExtractModelJson = Mid$(htmlText, openEnd + 1, closePos - openEnd - 1)
End Function

Private Function ReadUtf8File(ByVal path As String) As String
    Dim stream As Object
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 2
    stream.Charset = "utf-8"
    stream.Open
    stream.LoadFromFile path
    ReadUtf8File = stream.ReadText
    stream.Close
End Function

Private Sub WriteUtf8File(ByVal path As String, ByVal value As String)
    Dim stream As Object
    EnsureParentFolder path
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 2
    stream.Charset = "utf-8"
    stream.Open
    stream.WriteText value
    stream.SaveToFile path, 2
    stream.Close
End Sub

Private Sub EnsureParentFolder(ByVal path As String)
    Dim fso As Object
    Dim parent As String
    Set fso = CreateObject("Scripting.FileSystemObject")
    parent = fso.GetParentFolderName(path)
    If Len(parent) = 0 Or Not fso.FolderExists(parent) Then Err.Raise vbObjectError + 2070, , "Parent folder does not exist: " & parent
End Sub

Private Function ResolveAssetPath(ByVal htmlPath As String, ByVal asset As String) As String
    Dim fso As Object
    Dim resolved As String
    Set fso = CreateObject("Scripting.FileSystemObject")
    If InStr(1, asset, "://", vbTextCompare) > 0 Then Err.Raise vbObjectError + 2071, , "Remote assets are not supported: " & asset
    If fso.PathIsAbsolute(asset) Then
        resolved = asset
    Else
        resolved = fso.BuildPath(fso.GetParentFolderName(htmlPath), Replace(asset, "/", "\"))
    End If
    If Not fso.FileExists(resolved) Then Err.Raise vbObjectError + 2072, , "Asset not found: " & resolved
    ResolveAssetPath = resolved
End Function

Private Function FileExists(ByVal path As String) As Boolean
    FileExists = CreateObject("Scripting.FileSystemObject").FileExists(path)
End Function

Private Sub RequireAbsolutePath(ByVal path As String, ByVal label As String)
    If Not CreateObject("Scripting.FileSystemObject").PathIsAbsolute(path) Then
        Err.Raise vbObjectError + 2073, , label & " must be absolute: " & path
    End If
End Sub

Private Function ChangeExtension(ByVal path As String, ByVal newExtension As String) As String
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    ChangeExtension = fso.BuildPath(fso.GetParentFolderName(path), fso.GetBaseName(path) & newExtension)
End Function

Private Function SafeName(ByVal value As String) As String
    Dim i As Long, ch As String, result As String
    For i = 1 To Len(value)
        ch = Mid$(value, i, 1)
        If ch Like "[A-Za-z0-9_-]" Then result = result & ch Else result = result & "_"
    Next i
    If Len(result) = 0 Then result = "item"
    SafeName = Left$(result, 180)
End Function

Private Function UniqueShapeName(ByVal sld As Slide, ByVal desired As String, ByVal ownId As Long) As String
    Dim candidate As String, suffix As Long
    Dim shp As Shape
    candidate = Left$(desired, 240)
    Do
        Set shp = Nothing
        On Error Resume Next
        Set shp = sld.Shapes(candidate)
        On Error GoTo 0
        If shp Is Nothing Or shp.Id = ownId Then Exit Do
        suffix = suffix + 1
        candidate = Left$(desired, 230) & "_" & CStr(suffix)
    Loop
    UniqueShapeName = candidate
End Function

Private Function HexToRgb(ByVal value As String) As Long
    Dim hexValue As String
    hexValue = Replace(value, "#", "")
    If Len(hexValue) <> 6 Then Err.Raise vbObjectError + 2080, , "Color must be #RRGGBB: " & value
    HexToRgb = RGB(CLng("&H" & Left$(hexValue, 2)), CLng("&H" & Mid$(hexValue, 3, 2)), CLng("&H" & Right$(hexValue, 2)))
End Function

Private Function GetString(ByVal dictionary As Dictionary, ByVal key As String, ByVal fallback As String) As String
    If dictionary.Exists(key) Then GetString = CStr(dictionary(key)) Else GetString = fallback
End Function

Private Function GetNumber(ByVal dictionary As Dictionary, ByVal key As String, ByVal fallback As Double) As Double
    If dictionary.Exists(key) Then GetNumber = CDbl(dictionary(key)) Else GetNumber = fallback
End Function

Private Function GetBoolean(ByVal dictionary As Dictionary, ByVal key As String, ByVal fallback As Boolean) As Boolean
    If dictionary.Exists(key) Then GetBoolean = CBool(dictionary(key)) Else GetBoolean = fallback
End Function

Private Function MapShapeType(ByVal value As String) As Long
    Select Case LCase$(value)
        Case "rect", "rectangle": MapShapeType = 1
        Case "roundrect", "rounded-rectangle": MapShapeType = 5
        Case "ellipse", "oval", "circle": MapShapeType = 9
        Case "diamond": MapShapeType = 4
        Case "triangle": MapShapeType = 7
        Case "hexagon": MapShapeType = 10
        Case "chevron": MapShapeType = 52
        Case Else: MapShapeType = 1
    End Select
End Function

Private Function MapChartType(ByVal value As String) As Long
    Select Case LCase$(value)
        Case "column-clustered": MapChartType = 51
        Case "bar-clustered": MapChartType = 57
        Case "line": MapChartType = 4
        Case "pie": MapChartType = 5
        Case "area": MapChartType = 1
        Case "scatter": MapChartType = -4169
        Case Else: MapChartType = 51
    End Select
End Function

Private Function MapDashStyle(ByVal value As String) As Long
    Select Case LCase$(value)
        Case "solid": MapDashStyle = 1
        Case "dash": MapDashStyle = 4
        Case "dot": MapDashStyle = 3
        Case "dash-dot": MapDashStyle = 5
        Case "long-dash": MapDashStyle = 7
        Case Else: MapDashStyle = 1
    End Select
End Function

Private Function MapAutoSize(ByVal value As String) As Long
    Select Case LCase$(value)
        Case "fit-shape-to-text": MapAutoSize = 1
        Case "shrink-text-on-overflow": MapAutoSize = 2
        Case Else: MapAutoSize = 0
    End Select
End Function

Private Function MapVerticalAnchor(ByVal value As String) As Long
    Select Case LCase$(value)
        Case "middle": MapVerticalAnchor = 3
        Case "bottom": MapVerticalAnchor = 4
        Case Else: MapVerticalAnchor = 1
    End Select
End Function

Private Function MapTextAlignment(ByVal value As String) As Long
    Select Case LCase$(value)
        Case "center": MapTextAlignment = 2
        Case "right": MapTextAlignment = 3
        Case "justify": MapTextAlignment = 4
        Case Else: MapTextAlignment = 1
    End Select
End Function
