#!/bin/bash

echo "[INFO] --- MacBook Pro 13\" 2017: konfiguracja rozszerzona ---"

# 1. Ustawienia dla grafiki Intel i skalowania
echo "[INFO] Dodawanie opcji i915 do GRUB..."
sudo sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="i915.enable_psr=0 /' /etc/default/grub
sudo update-grub

# 2. Jasność ekranu przez brightnessctl, jeśli xbacklight nie działa
echo "[INFO] Instalacja brightnessctl do kontroli jasności..."
sudo apt install -y brightnessctl
echo 'ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"' | sudo tee /etc/udev/rules.d/90-backlight.rules > /dev/null
echo 'ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"' | sudo tee -a /etc/udev/rules.d/90-backlight.rules > /dev/null
sudo usermod -aG video $USER

# 3. Dźwięk — Cirrus Logic fix (w razie braku dźwięku)
echo "[INFO] Dodawanie parametru model=mbp13 do ALSA (Cirrus Logic)..."
echo "options snd_hda_intel model=mbp13" | sudo tee /etc/modprobe.d/alsa-base.conf > /dev/null

# 4. Wentylator (opcjonalnie) — MacFanCtl
echo "[INFO] Instalacja narzędzia do sterowania wentylatorem (macfanctld)..."
sudo apt install -y macfanctld
sudo systemctl enable macfanctld
sudo systemctl start macfanctld

# 5. Lepsze zarządzanie energią
echo "[INFO] Ustawianie parametrów pstate i i915..."
echo "options intel_pstate=active" | sudo tee /etc/modprobe.d/intel_pstate.conf > /dev/null
echo "options i915 enable_fbc=1 enable_psr=0" | sudo tee /etc/modprobe.d/i915.conf > /dev/null

# 6. Dodatkowe gesty (jeśli masz fusuma)
echo "[INFO] Dodawanie przykładowych gestów 4-palczastych do Fusuma..."
mkdir -p ~/.config/fusuma
cat << EOF > ~/.config/fusuma/config.yml
swipe:
  4:
    left: 'super+Left'
    right: 'super+Right'
    up: 'ctrl+alt+Up'
    down: 'ctrl+alt+Down'
pinch:
  in:
    command: 'xdotool key ctrl+plus'
  out:
    command: 'xdotool key ctrl+minus'
threshold:
  swipe: 0.5
  pinch: 0.2
interval:
  swipe: 0.8
  pinch: 1
eof
EOF

echo "[INFO] Gotowe! Uruchom ponownie komputer, aby zastosować wszystkie zmiany."
