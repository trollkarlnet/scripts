#!/bin/sh

set -x 
OPENSSL=/usr/bin/openssl
MKTEMP=/bin/mktemp
DD=/bin/dd
if [ -z $1 ]; then

	echo "Usage: `basename $0` CERT"
	exit 255
fi
BASENAME=`basename $0`

TMP1=`${MKTEMP} /tmp/${BASENAME}.1.XXXXXXXXXX`
TMP2=`${MKTEMP} /tmp/${BASENAME}.2.XXXXXXXXXX`
TMP3=`${MKTEMP} /tmp/${BASENAME}.3.XXXXXXXXXX`
TMP4=`${MKTEMP} /tmp/${BASENAME}.4.XXXXXXXXXX`

${DD} if=/dev/urandom of=${TMP1} bs=1k count=4
${DD} if=/dev/urandom of=${TMP2} bs=2k count=4
${DD} if=/dev/urandom of=${TMP3} bs=4k count=4
${DD} if=/dev/urandom of=${TMP4} bs=8k count=4


${OPENSSL} genrsa -aes256 -rand ${TMP1}:${TMP2}:${TMP3}:${TMP4} -out $1.key 2048

if [ ! -e $1.key ]; then

	echo "Can not generate CSR Missing $1.key" 
	exit 255
fi

${OPENSSL} req -new -key $1.key -out $1.csr

if [ ! -e $1.csr ] ; then
	echo "Can not generate 60 day self-signed certificate Missing $1.csr" 
	exit 255
fi

${OPENSSL} x509 -req  -days 60 -in $1.csr -signkey $1.key -out $1.crt

${OPENSSL} rsa -in $1.key -out $1.pem

if [ -e ${TMP1} ] ; then  rm ${TMP1} ; fi
if [ -e ${TMP2} ] ; then  rm ${TMP2} ; fi
if [ -e ${TMP3} ] ; then  rm ${TMP3} ; fi
if [ -e ${TMP4} ] ; then  rm ${TMP4} ; fi

exit 0
