-- 渡されたファイルを Rex の edit セッションの nvim で開くアプリ。
-- .lua などの既定のアプリにすると、Finder や Rex の警告から開いたファイルが nvim で開く。
-- ビルド: osacompile -o ~/Applications/"Rex nvim.app" ~/.config/rex/open-in-nvim.applescript

on open theFiles
	set rex to "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex"
	repeat with f in theFiles
		set p to POSIX path of f
		set cmd to "R=" & quoted form of rex & "; P=" & quoted form of p & "; D=$(dirname \"$P\"); " & ¬
			"if \"$R\" ls | awk 'NR>1 {print $1}' | grep -qx edit; then " & ¬
			"\"$R\" run -s edit -c \"$D\" --label nvim -- nvim \"$P\"; " & ¬
			"else \"$R\" new edit -c \"$D\" -- nvim \"$P\"; fi"
		do shell script cmd
	end repeat
	tell application "Rex Beta" to activate
end open
