##  Message catalogs for internationalization.
##    Copyright (C) 1995-2019 Free Software Foundation, Inc.
##    This file is part of the GNU C Library.
##    This file is derived from the file libgettext.h in the GNU gettext package.
##
##    The GNU C Library is free software; you can redistribute it and/or
##    modify it under the terms of the GNU Lesser General Public
##    License as published by the Free Software Foundation; either
##    version 2.1 of the License, or (at your option) any later version.
##
##    The GNU C Library is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
##    Lesser General Public License for more details.
##
##    You should have received a copy of the GNU Lesser General Public
##    License along with the GNU C Library; if not, see
##    <http://www.gnu.org/licenses/>.

when defined(windows):
  const libintl* = "libintl.dll"
elif defined(macosx):
  const libintl* = "libintl.dylib"
else:
  const libintl* = "libc.so.6"


##  We define an additional symbol to signal that we use the GNU
##    implementation of gettext.

const USE_GNU_GETTEXT* = 1

##  Provide information about the supported file formats.  Returns the
##    maximum minor revision number supported for a given major revision.

template GNU_GETTEXT_SUPPORTED_REVISION*(major: untyped): untyped =
  (if (major) == 0: 1 else: -1)

##  Look up MSGID in the current default message catalog for the current
##    LC_MESSAGES locale.  If not found, returns MSGID itself (the default
##    text).

proc gettext*(msgid: cstring): cstring {.importc: "gettext", dynlib: libintl.}
##  Look up MSGID in the DOMAINNAME message catalog for the current
##    LC_MESSAGES locale.

proc dgettext*(domainname: cstring; msgid: cstring): cstring {.
    importc: "dgettext", dynlib: libintl.}
##  Look up MSGID in the DOMAINNAME message catalog for the current CATEGORY
##    locale.

proc dcgettext*(domainname: cstring; msgid: cstring; category: cint): cstring {.
    importc: "dcgettext", dynlib: libintl.}
##  Similar to `gettext' but select the plural form corresponding to the
##    number N.

proc ngettext*(msgid1: cstring; msgid2: cstring; n: culong): cstring {.
    importc: "ngettext", dynlib: libintl.}
##  Similar to `dgettext' but select the plural form corresponding to the
##    number N.

proc dngettext*(domainname: cstring; msgid1: cstring; msgid2: cstring;
               n: culong): cstring {.importc: "dngettext", dynlib: libintl.}
##  Similar to `dcgettext' but select the plural form corresponding to the
##    number N.

proc dcngettext*(domainname: cstring; msgid1: cstring; msgid2: cstring;
                n: culong; category: cint): cstring {.importc: "dcngettext",
    dynlib: libintl.}
##  Set the current default message catalog to DOMAINNAME.
##    If DOMAINNAME is null, return the current default.
##    If DOMAINNAME is "", reset to the default of "messages".

proc textdomain*(domainname: cstring): cstring {.importc: "textdomain",
    dynlib: libintl.}
##  Specify that the DOMAINNAME message catalog will be found
##    in DIRNAME rather than in the system locale data base.

proc bindtextdomain*(domainname: cstring; dirname: cstring): cstring {.
    importc: "bindtextdomain", dynlib: libintl.}
##  Specify the character encoding in which the messages from the
##    DOMAINNAME message catalog will be returned.

proc bind_textdomain_codeset*(domainname: cstring; codeset: cstring): cstring {.
    importc: "bind_textdomain_codeset", dynlib: libintl.}
##  Optimized version of the function above.
##  #if defined OPTIMIZE && !defined cplusplus
##  We need NULL for `gettext'.

const
  need_NULL* = true

##  We need LC_MESSAGES for `dgettext'.

##  These must be macros.  Inlined functions are useless because the
##    `builtin_constant_p' predicate in dcgettext would always return
##    false.

# template gettext*(msgid: untyped): untyped =
#   dgettext(nil, msgid)

# template dgettext*(domainname, msgid: untyped): untyped =
#   dcgettext(domainname, msgid, LC_MESSAGES)

# template ngettext*(msgid1, msgid2, n: untyped): untyped =
#   dngettext(nil, msgid1, msgid2, n)

# template dngettext*(domainname, msgid1, msgid2, n: untyped): untyped =
#   dcngettext(domainname, msgid1, msgid2, n, LC_MESSAGES)

template _*(msgid: string): string =
  $gettext(msgid)


# From locale.h:
const
  LC_CTYPE* = 0
  LC_NUMERIC* = 1
  LC_TIME* = 2
  LC_COLLATE* = 3
  LC_MONETARY* = 4
  LC_MESSAGES* = 5
  LC_ALL* = 6
  LC_PAPER* = 7
  LC_NAME* = 8
  LC_ADDRESS* = 9
  LC_TELEPHONE* = 10
  LC_MEASUREMENT* = 11
  LC_IDENTIFICATION* = 12

##  Set and/or return the current locale.
proc setlocale*(category: cint; locale: cstring): cstring {.cdecl,
    importc: "setlocale", dynlib: libintl.}