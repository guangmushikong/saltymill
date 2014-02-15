prereqs:
  pkg.installed:
    - names: [ unzip, wget ]
    - require_in: cartogothic

# Bah, the old source (fontsquirrel) doesn't have this font anymore. Not sure if this .otf version will work.
fonts:
  cmd.run:
    - cwd: /usr/share/fonts/truetype
    - name: |
        wget 'http://www.freefontspro.com/d/12524/cartogothic_std.zip' 
        unzip -d CartoGothic -o *.zip
    - unless: test -d /usr/share/fonts/truetype/CartoGothic

fonts_logdone:
  cmd.wait:
    - name: |
        echo "Fonts downloaded and unzipped." >> /var/log/salt/buildlog.html
    - watch: [ { cmd: fonts } ]
