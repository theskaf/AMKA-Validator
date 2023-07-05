# AMKA-Validator
Validates AMKA (Greek Social Security) numbers.


AMKA (Greek Social Security Number) has the following 11-digit format: YYMMDDxxxyz, where 
- the first 6 digits encode the person’s date of birth (YYMMDD), 
- the following 4 digits are a sequence number for people born on that date (xxxy) 
( the sex of the person is encoded in the last digit of the sequence number (y of xxxy): even digits are assigned to women and odd digits are assigned to men )
- and the last digit is a control digit (z) computed by the Luhn algorithm. 

This program validates exactly the points above. Written in Delphi with FMX (can be built for Windows and Android).

With that being said, here's an interesting read about the failure in the implementation of AMKA: 
A Greek (Privacy) Tragedy: The Introduction of Social Security Numbers in Greece: https://publications.ics.forth.gr/_publications/ssn.wpes09.pdf
