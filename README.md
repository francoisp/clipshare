This does clipboard sharing over ssh between a mac and a remove X machine. x0vncserver (tigervnc) currently does not implement clipboard sharing so this does it, not super elegant but works for now.

requires rsync at both ends, xclip on the x0vnc end and pbpaste and pbcopy on the mac end. (or equivalent for windows, not using that atm)

if you are a mac user. check this out!: https://github.com/artginzburg/MiddleClick
