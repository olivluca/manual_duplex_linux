# Manual Duplex Printing for Linux
Driver for manual duplex (double side printing) for linux printers. Duplexer unit for linux printers.
This fork has been modified for the paper flow of a Pantum MW6500W printer.

The most intuitive and simple manual duplex driver for linux:
- It depends on pdftk as a workaround for [this bug](https://github.com/OpenPrinting/cups-filters/issues/541)
- No compliling,
- Short and simple bash script.

## HOW TO
1. Make sure your printer is installed;
2. Run ./install.sh as root;
3. Send print jobs to your new manual_duplex printer;
4. Sit back and sip a coffe.


## About
This driver installs a virtual printer on top of the printer you choose at the install prompt.
Will print odd pages, will display a window with instructions in which you click "proceed" after you flip the finished odd pages.

So most of the settings are done in your phisical printer.
If you have more than one printer, you can run install.sh for every printer.

This is actually a "print to script" driver; the script is in usr/(...)/backends/ .

Inspired by:
- https://askubuntu.com/questions/981020/use-a-script-as-a-printer-to-process-output-pdf
- https://unix.stackexchange.com/questions/137081/using-a-shell-script-as-a-virtual-printer
