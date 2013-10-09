#enforce dvorak layout
sed -e 's/^XKBMODEL="SKIP"/XKBMODEL="pc104"/' -e 's/^XKBVARIANT=""/XKBVARIANT="dvorak"/' -e 's/^XKBLAYOUT=""/XKBLAYOUT="us"/' /etc/default/keyboard | sudo tee /etc/default/keyboard
dpkg-reconfigure -f noninteractive keyboard-configuration