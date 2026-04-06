---
title:LXQt
date:2026-03-18
template:post.html
---

I'm not usually one to fiddle with computer setups, my usual 
go-to is Fedora with Xfce or gnome. But I recently acquired a laptop that

1. Can't boot my usual distros due to a now-fixed but
  not yet released [bug](https://bugzilla.redhat.com/show_bug.cgi?id=2263643#c118)
2. Has a touchscreen so would benefit from Wayland's improved support for touch gestures
  via libinput (so I can pinch and stretch my PDFs)
3. Is ~six years old, so is a little sluggish with KDE or Gnome these days
  in comparison to Xfce.

I was motivated to try [LXQt](https://lxqt-project.org/), another lightweight xfce-like desktop
environment which now has support for wayland.

LXQt is separated into the window manager (Xfwm), compositor (Labwc)
and uh, desktop environment (LXQt).

This took a bit of fiddling with the labwc config, mostly to set up
the keyboard shortcuts I am used to.

### I swap caps and escape because I'm a loser neovim user


noting this here for next time I have to set this and forget;

`/etc/labwc/environment`

```
XKB_DEFAULT_OPTIONS=caps:swapescape
```

#### Desktop Portals

I ended up installing debian and had a bad time its old packages,
trying to fill the gaps with flatpak and/or nix proved painful: mainly due to 
fighting `xdg-desktop-portal`.

In the end I think just installing everything _probably_ makes it all work:

```
apt install xdg-desktop-portal  xdg-desktop-portal-gnome pipewire
systemctl status --user xdg-desktop-portal
```

...and so on.

In `.profile` and `.bashrc` for good measure:

```
export GTK_USE_PORTAL=1
```

because a forum user told me to.


#### Verdict

Lxqt/labwc is pretty nice, gestures work and so on. Its not really as polished
or simple to set up yet (though I feel this could mostly be sorted out on the
distro level?). Its suits the same workflow as as xfce and is similarly
lightweight and animation-free. Its definitely good enough that I'm
willing to go to the effort, which is a high bar for me.


Update: labwc is not the primary supported window manager, the experience under KWin may be better.
