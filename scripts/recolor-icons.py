#!/usr/bin/env python3
"""Builds ~/.icons/Papirus-Crimson: Papirus-Dark with red folders and crimson-recolored app icons."""
import os, re, glob
T = os.path.expanduser('~/.icons/Papirus-Crimson')
SRC = '/usr/share/icons/Papirus'
pal = [(0.0,'#3A0A14'),(0.25,'#64101F'),(0.45,'#8A1C30'),(0.62,'#B51F3B'),(0.8,'#D93A57')]
rx = re.compile(r'#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b')
def m(h):
    h = h.group(0)[1:]
    if len(h) == 3: h = ''.join(c*2 for c in h)
    r,g,b = (int(h[i:i+2],16)/255 for i in (0,2,4))
    l = 0.299*r + 0.587*g + 0.114*b
    if max(r,g,b)-min(r,g,b) < 0.08 and (l > 0.85 or l < 0.12): return '#'+h
    if l > 0.85: return '#E8E2E3'
    c = pal[0][1]
    for t,v in pal:
        if l >= t: c = v
    return c
sizes = ['16x16','22x22','24x24','32x32','48x48','64x64']
dirs, sections = [], ''
for s in sizes:
    for ctx, sub in (('Places','places'),('Applications','apps')):
        src = f'{SRC}/{s}/{sub}'
        if not os.path.isdir(src): continue
        d = f'{T}/{s}/{sub}'; os.makedirs(d, exist_ok=True)
        if sub == 'places':
            for f in glob.glob(src+'/folder-red*.svg') + glob.glob(src+'/user-red*.svg'):
                dst = d+'/'+os.path.basename(f).replace('-red','',1)
                if os.path.lexists(dst): os.remove(dst)
                os.symlink(f, dst)
        else:
            for f in glob.glob(src+'/*.svg'):
                try: t = open(os.path.realpath(f)).read()
                except Exception: continue
                open(d+'/'+os.path.basename(f),'w').write(rx.sub(m,t))
        dirs.append(f'{s}/{sub}')
        sections += f'\n[{s}/{sub}]\nSize={s.split("x")[0]}\nContext={ctx}\nType=Fixed\n'
# extra app icons not in Papirus (Prism Launcher)
prism = '/var/lib/flatpak/exports/share/icons/hicolor/scalable/apps/org.prismlauncher.PrismLauncher.svg'
if os.path.exists(prism):
    os.makedirs(T+'/scalable/apps', exist_ok=True)
    open(T+'/scalable/apps/org.prismlauncher.PrismLauncher.svg','w').write(rx.sub(m, open(prism).read()))
    dirs.append('scalable/apps')
    sections += '\n[scalable/apps]\nSize=256\nMinSize=16\nMaxSize=512\nContext=Applications\nType=Scalable\n'
open(T+'/index.theme','w').write('[Icon Theme]\nName=Papirus-Crimson\nInherits=Papirus-Dark,Papirus,hicolor\nDirectories='+','.join(dirs)+'\n'+sections)
print('Papirus-Crimson built')
