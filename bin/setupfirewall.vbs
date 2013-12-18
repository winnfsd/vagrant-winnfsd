Set UAC = CreateObject("Shell.Application")
For count = 0 to (WScript.Arguments.Count - 1)
    UAC.ShellExecute "netsh", Replace(WScript.Arguments(count), "'", Chr(34)), "", "runas", 1
Next