valac --pkg gtk+-3.0 --pkg granite src/Wallpaperize.vala

sudo mkdir /usr/share/wallpaperize
sudo cp Wallpaperize /usr/share/wallpaperize/Wallpaperize
sudo cp src/wapaperize.contract /usr/share/contractor/wapaperize.contract

echo "Wallpaperize instalation done! Enjoy"
