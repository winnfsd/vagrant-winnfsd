Set UAC = CreateObject("Shell.Application")
UAC.ShellExecute "netsh", Replace(WScript.Arguments(0), "'", Chr(34)), "", "runas", 1
UAC.ShellExecute "netsh", Replace(WScript.Arguments(1), "'", Chr(34)), "", "runas", 1