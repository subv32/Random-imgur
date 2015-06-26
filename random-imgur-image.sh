#!/bin/bash
while :
do
   #Generate an ID, 7 characters, a-z A-Z 0-9
   id=$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 7 | tr -d '\n'; echo)
   #Construct the URL
   url="http://imgur.com/$id"

   req=$(curl -s -D - $url)
   echo "Trying.. $url"
   #Make sure we get a 200 Code.. We don't want 404s, 502s, 302s, etc
   isFourOhFor=$(echo -e "$req" | head -1)
   if [[ $isFourOhFor != *200* ]]; then continue; fi

   #Sometimes a blank response might happen.
   #Strange issue and difficult to reproduce so we'll just check for it
   contentLength=$(echo -e "$req" | grep Content-Length | awk {'print $2'} | tr -d [:space:])

   if [[ "$contentLength" -eq "0" ]]; then continue; fi

   #Find the file
  file=$(echo -e "$req" | grep $id | grep content | awk {'print $3'} | sed s/'content="'// | tr -d '"' | grep -v "?" | sed s/"\/>"// | tail -1)
   
   echo "Found! $file"
   #Download the file
   wget -q $file
   
   #This break means we only download ONE image. Comment the break
   #for this to continue running after finding one
   break
done
