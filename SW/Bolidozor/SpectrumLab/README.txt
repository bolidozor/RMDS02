Detection station management system
-----------------------------------

SKELETON-R1.usr should be imported in to SpectrumLab software as settings file. 

After import of usr file. Detection script must be modified to match station name and location of data storage. This should be modified on this line: 

if( initialising ) then id_met="no":id_met2="no":K_station_name="SVAKOV-R2":K_path="/media/sd/meteors/"

Where "SVAKOV-R2" is string - name of detection station. It must be less than 20 characters without spaces.

The path "/media/sd/meteors/" poits to direcetory, where data records will be stored. In this directory must already exist this scructure: 

── SVAKOV-R2
    ├── audio
    ├── capture
    ├── data

File and directory permissions must be matched to user running Spectrumlab.


Receiver tunning
----------------

the receiver must be propertly tunned in order to match frequency center of meteor echoes to 10600 Hz on frequency axis in SpetcrumLab waterfall.

See station setup manual at http://wiki.bolidozor.cz/doku.php?id=cs:spectrumlab for more information. 

Data upload
-----------

Other shell script is used for data management of meteor records. 
This scripts should be used to upload data to Bolidozor server. But this action needs ssh public key authentication.  

see http://wiki.bolidozor.cz/doku.php?id=cs:registration for details.

Sorting of local data record can be done by Tidyup.sh even without publication and registration.



