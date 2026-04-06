---
title:Portégé
date:2026-03-25
template:post.html
---

I love a 5-year old laptop. I have owned my share of old thinkpads, but as a
good researcher one must question: are there still yet-undiscovered
_non-thinkpad_ laptops? 

Searching recently for especially light laptops I came across the `Dynabook
X30L-J` and companion tablet-style device `X30W-J`. These are little 13"
laptops that weigh _under 1kg_, in fact the `X30L-J` is only 906g (as
marketed). This is comparable to a Steamdeck (without case) or 11" Android
tablet (with case).

Not only that, but in this form factor it still has _ports_:

- 2x usb-a
- RJ45 Ethernet (!!) (with a full metal socket no fragile plastic clippy hinge
things)
- HDMI
- 3.5mm audio
- 2x usb-C thunderbolt

It also has a blue trackpoint mouse which is very cool, and 
a suprisingly nice keyboard (subjectively). 

This is obviously not an advertisement for a discontinued product,
I'm just shocked they still made decives like this in 2020. A normal laptop. A
gift of sanity I wasn't expecting.

---

But you must always be careful when buying a non-thinkpad laptop—will it be
able to run Linux?

Granted, this laptop is six years old so hardware support
is probably okay. Even better, searching online
I found a delightful homebrew
[tech support manual](https://7rocks.com/downloads/manual_toshiba_dynabook_portege_X30L_J/20211012_tech_manual_toshiba_dynabook_portege_x30L-J.pdf)
on installing Linux Mint 20, which incidentally also has the goal of

> making a standard fully open source system from the first transistor and
> screw to the final polished user interface.

which strikes me as a particularly lofty ambition to tackle with a pdf.

Moreover we find this ringing endorsement of the laptop,

> My old boss from 20 years ago still stands by and sells Toshiba;

and this insight into Linux,

> The issue with Linux is that it is too configurable and when the standard user
> talks to Linux Nerds they get too much info and too many options.

which I may be inclined to agree with.

Unfortunately I'm not enough of a Linux nerd to run Fedora rawhide (the release
tracking the nightly build of the entire OS and package system straight from
the upstream git repos), as would be required to get the fix for this
[boot-preventing fedora bug](https://bugzilla.redhat.com/show_bug.cgi?id=2263643)
before it makes it into a release. I believe it might be unstable and cause
some amount of trouble when really I just want to write OCaml and compile LaTeX.

Luckily I've been corrected on the pronounciation of "Linux" by divorced 49yo
Trump supporters[^1] hanging around bars waiting to pick their son up from his
casual job, enough times[^2] to figure out how to install my _second_ favourite
distro, [debian](/posts/de-wayland.html). I later took this saga as an excuse
to install Arch again and the auto install script,
[archinstall](https://wiki.archlinux.org/title/Archinstall), was
simple enough and I'm enjoying the large up-to-date package repository so far.

#### Summary

##### X30W-J (convertible)

- RHEL-lineage (Fedora, CentOS, OpenSUSE) grub bug prevents boot of some Linux distros: [bugzilla](https://bugzilla.redhat.com/show_bug.cgi?id=2263643)
- I could not get the webcam to work—uninvestigated

#### X30L-J (laptop)

This does happily boot SUSE and the webcam works.

- Power control issue seems to make it stop-start charging status; I haven't looked into this
- Spurious wakeup events from some device prevent it from staying in suspend:
  fixed by silencing the events with the following file `/etc/tmpfiles.d/disable-thunderbolt-wake.conf`:


```
#    Path                  Mode UID  GID  Age Argument
w    /sys/bus/pci/devices/0000:00:1c.0/power/wakeup    -    -    -    -    disabled
w    /proc/acpi/wakeup    -    -    -    -    XHC
```

The [arch wiki](https://wiki.archlinux.org/title/Power_management/Wakeup_triggers#Instantaneous_wakeup_after_suspending) and [this blog
post](https://web.archive.org/web/20251206064440/https://www.marcusfolkesson.se/blog/determine-wakeup-cause-with-acpi/)
was helpful but ultimately I resorted to going through every device see if it
woke the laptop up.

---

This makes the Linux compatibility a bit mixed: this bug is an exceptional
case and the fix will be released soon. Debian runs flawlessly as far as
hardware support is concerned.


### Conclusion

Having covered the two critical axes of computign: ports, and Linux, this
concludes my review of a laptop that surprised me with its
anachronistically sensible design. It also has a screen and keyboard and
trackpad. They can be found at refurbished computer retailers like untech,
australian-computer-traders, and recompute for \$350-\$700 depending on
quality and configuration. 

I accept my newfound title of "Consumer Tech Blogger".


[^1]: It rhymes with "Linus" I'm told.
[^2]: One time.


