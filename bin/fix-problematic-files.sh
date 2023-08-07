#!/bin/bash
# Idealy this script shouldnt be used - it ads some spaces around several notes, to avoid notes inside tokens

echo "BEGIN fix-problematic-files"


perl -pi -e 's@<note>In</note>seguras@(In)seguras@' CD210311-PM.xml
perl -pi -e 's@es<note>criminal</note>1@es <note>criminal</note>@' CD210519-PM.xml
perl -pi -e 's@-<note>risas</note>-@<note>risas</note>@' CD220202-PM.xml
perl -pi -e 's@señorías<note>risas y aplausos</note>-@señorías <note>risas y aplausos</note>-@' CD220712-PM.xml
perl -pi -e 's@calle<note>aplausos</note>-@calle <note>aplausos</note>-@' CD221122-PM.xml
perl -pi -e 's@</note>-<note>@</note><note>@' CD221124-PM.xml


echo "END fix-problematic-files"


