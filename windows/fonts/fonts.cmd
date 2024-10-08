copy c:\Windows\Fonts\conso*.ttf .\fonts\in
docker run --rm -v .\fonts\in:/in -v .\fonts\out:/out nerdfonts/patcher
