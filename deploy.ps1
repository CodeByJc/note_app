flutter build web --release --base-href="/note_app/"
git worktree add build/gh1-pages gh1-pages
Remove-Item -Recurse -Force build/gh1-pages/*
Copy-Item -Recurse build/web/* build/gh1-pages/
Set-Location build/gh1-pages
git add .
git commit -m "Deploy web"
git push origin gh1-pages
Set-Location ../..
git worktree remove build/gh1-pages
Write-Host "✅ Deployed to https://codebyjc.github.io/note_app/"
