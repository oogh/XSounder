PROJECT=./examples/Android/XSound
APP=$PROJECT/app
CORERENDER=$PROJECT/coresound

rm -rf $PROJECT/.gradle
rm -rf $PROJECT/.idea
rm $PROJECT/*.iml

rm -rf $APP/build
rm $APP/*.iml

rm -rf $CORERENDER/.cxx
rm -rf $CORERENDER/build
rm $CORERENDER/*.iml
