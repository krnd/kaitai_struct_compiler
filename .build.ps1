TASK .     build
TASK build build:all
TASK run   build:all, run:csharp_krnd
TASK rerun run:csharp_krnd
TASK clean clean:build


################### VARIABLES ##############################

$PlaygroundDir         = "$PSScriptRoot\krnd-playground"
$KSTestFile            = "$PlaygroundDir\test-file.ksy"

$BatchTargetName       = "kaitai-struct-compiler.bat"

$WindowsBuildDir       = "jvm\target\windows"
$WindowsRunDirectory   = "$WindowsBuildDir\bin"
$WindowsBatchTarget    = "$WindowsRunDirectory\$BatchTargetName"


################### BUILD ##################################

TASK build:all build:compiler, build:batch

TASK build:compiler {
    EXEC { sbt compilerJVM/windows:packageBin }
}

TASK build:batch {
    $tempFileHandle = New-TemporaryFile
    $tempFile = [System.IO.File]::CreateText($tempFileHandle)
    $lineNumber = 0
    foreach ($line in [System.IO.File]::ReadLines($WindowsBatchTarget)) {
        $lineNumber++
        if (($lineNumber -ge 13) -and ($lineNumber -le 20) -and ($lineNumber -ne 14))
            { continue }
        $tempFile.WriteLine($line)
    }
    $tempFile.Close()
    Move-Item -Force $tempFileHandle $WindowsBatchTarget
}


################### RUN ####################################

TASK run:csharp_krnd {
    Set-Location $WindowsRunDirectory
    & ".\$BatchTargetName" `
        --target csharp_krnd `
        --outdir $PlaygroundDir `
        --dotnet-namespace MyNamespace `
        --dotnet-baseclass MyBaseClass `
        --dotnet-common-baseclass MyCommonBaseClass `
        --dotnet-skip-prefix skip_ `
        --dotnet-internal-prefix x_ `
        $KSTestFile
}


################### CLEAN ##################################

TASK clean:build {
    REMOVE $WindowsBuildDir
}
