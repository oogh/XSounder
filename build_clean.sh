# andorid example clean

echo "[CLEAN] Begin!"

if [ -d "$PROJ_ANDROID/.gradle" ]; then
    rm -rf $PROJ_ANDROID/.gradle
    echo "[CLEANing] $PROJ_ANDROID/.gradle"
fi

if [ -d "$PROJ_ANDROID/.idea" ]; then
    rm -rf $PROJ_ANDROID/.idea
    echo "[CLEANing] $PROJ_ANDROID/.idea"
fi

if [ -d "$PROJ_ANDROID/build" ]; then
    rm -rf $PROJ_ANDROID/build
    echo "[CLEANing] $PROJ_ANDROID/build"
fi

if [ -f "$PROJ_ANDROID/*.iml" ]; then
    rm -rf $PROJ_ANDROID/*.iml
    echo "[CLEANing] $PROJ_ANDROID/*.iml"
fi

if [ -d "$APP/build" ]; then
    rm -rf $APP/build
    echo "[CLEANing] $APP/build"
fi

if [ -f "$APP/*.iml" ]; then
    rm $APP/*.iml
    echo "[CLEANing] $APP/*.iml"
fi

if [ -d "$CORESOUND/.cxx" ]; then
    rm -rf $CORESOUND/.cxx
    echo "[CLEANing] $CORESOUND/.cxx"
fi

if [ -d "$CORESOUND/build" ]; then
    rm -rf $CORESOUND/build
    echo "[CLEANing] $CORESOUND/build"
fi

if [ -f "$CORESOUND/*.iml" ]; then
    rm $CORESOUND/*.iml
    echo "[CLEANing] $CORESOUND/*.iml"
fi

# ios example clean
PROJ_IOS=./examples/iOS/XSound

if [ -f "$PROJ_IOS/Podfile.lock" ]; then
    rm $PROJ_IOS/Podfile.lock
    echo "[CLEANing] $PROJ_IOS/Podfile.lock"
fi

if [ -d "$PROJ_IOS/Pods" ]; then
    rm -rf $PROJ_IOS/Pods
    echo "[CLEANing] $PROJ_IOS/Pods"
fi

if [ -d "$PROJ_IOS/XSound.xcworkspace" ]; then
    rm -rf $PROJ_IOS/XSound.xcworkspace
    echo "[CLEANing] $PROJ_IOS/XSound.xcworkspace"
fi

echo "[CLEAN] Done!"
