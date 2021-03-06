Description
===========

Recovers the content of a git repository through a wrongly vulnerable web
server.

Why ?
=====

The case happened on a pentest, this was a POC used to demonstrate that in
such circumstances it is possible to recover all server-side source code as
well as the history. If Nmap warns you about a .git directory being
accessible know that this is a real issue.

Documentation
=============

::

    Usage: ./git-pwny.sh [-h] URL

    Options:
        -h, --help  Print this help and exit.

    Arguments:
        URL         URL pointing to the .git directory

License
=======

The code is under the WTFPL (see http://www.wtfpl.net/) License.

Contact
=======

::

    Main developper: Cédric Picard
    Email:           cpicard@openmailbox.org
