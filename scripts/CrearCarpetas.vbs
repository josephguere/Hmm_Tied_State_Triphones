Dim oFSO
Dim strDirBuild
Dim i
Set oFSO = CreateObject("Scripting.FileSystemObject")
DirectorioCompleto = "D:\htk"
	If Not oFSO.FolderExists(DirectorioCompleto) Then
	oFSO.CreateFolder DirectorioCompleto
	oFSO.CreateFolder DirectorioCompleto&"\data"
	oFSO.CreateFolder DirectorioCompleto&"\dictionary"
	oFSO.CreateFolder DirectorioCompleto&"\dictionary\bin"
	oFSO.CreateFolder DirectorioCompleto&"\dictionary\lexicon"
	oFSO.CreateFolder DirectorioCompleto&"\dictionary\Tutorial"
	oFSO.CreateFolder DirectorioCompleto&"\models"
	oFSO.CreateFolder DirectorioCompleto&"\scripts"
	oFSO.CreateFolder DirectorioCompleto&"\data\train"

	For i = 0 To 15
    		strDirBuild = "D:\htk\models\hmm"&i
    		oFSO.CreateFolder strDirBuild
	Next
	Msgbox "El Directorio ha sido creado satisfactoriamente"
Else
	Msgbox "El Directorio ya esta creado"
End If
