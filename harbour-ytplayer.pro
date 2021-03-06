# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-ytplayer

CONFIG += sailfishapp sailfishapp_no_deploy_qml
QT += dbus sql concurrent

SOURCES += \
        src/YTPlayer.cpp \
        src/NativeUtil.cpp \
        src/Logger.cpp \
        src/Prefs.cpp \
        src/YTRequest.cpp \
        src/YTListModel.cpp \
        src/YTNetworkManager.cpp \
        src/YTLocalVideo.cpp \
        src/YTLocalVideoData.cpp \
        src/YTLocalVideoManager.cpp \
        src/YTLocalVideoListModel.cpp \
        src/YTVideoDownloadNotification.cpp \
        src/YTVIdeoUrlFetcher.cpp

HEADERS += \
        src/YTPlayer.h \
        src/NativeUtil.h \
        src/Logger.h \
        src/Prefs.h \
        src/YTRequest.h \
        src/YTListModel.h \
        src/YTNetworkManager.h \
        src/YTLocalVideo.h \
        src/YTLocalVideoData.h \
        src/YTLocalVideoManager.h \
        src/YTLocalVideoListModel.h \
        src/YTVideoDownloadNotification.h \
        src/YTVideoUrlFetcher.h

QML_SOURCES = \
        qml/*.qml \
        qml/pages/*.qml \
        qml/cover/*.qml \
        qml/common/*.qml \
        qml/common/*.js

OTHER_FILES += \
        $$QML_SOURCES \
        harbour-ytplayer.desktop \
        scripts/mcc-data-util.py \
        scripts/generate-config-h.py \
        scripts/get_version_str.sh \
        rpm/harbour-ytplayer.spec

include(third_party/notifications.pri)
include(third_party/youtube_dl.pri)
include(languages/translations.pri)

!exists($${top_srcdir}/youtube-data-api-v3.key) {
    error("YouTube data api key file not found: youtube-data-api-v3.key")
}
!exists($${top_srcdir}/youtube-client-id.json) {
    warning("YouTube client ID file not found, client authotization won't work!")
}

KEY_FILE = $$top_srcdir/youtube-data-api-v3.key
CLIENT_ID_FILE = $$top_srcdir/youtube-client-id.json

configh.input = KEY_FILE
configh.output = $$top_builddir/config.h
configh.commands = \
    $$top_srcdir/scripts/generate-config-h.py \
            --keyfile=$$KEY_FILE \
            --idfile=$$CLIENT_ID_FILE \
            --outfile=$$top_builddir/config.h
configh.CONFIG += no_link

QMAKE_EXTRA_COMPILERS += configh
PRE_TARGETDEPS += compiler_configh_make_all

DEFINES += VERSION_STR=\\\"$$system($${top_srcdir}/scripts/get_version_str.sh)\\\"

licenses.files = $$files($$top_srcdir/LICENSE.*)
licenses.path = /usr/share/$${TARGET}/licenses
INSTALLS += licenses

lupdate_only {
SOURCES += $$QML_SOURCES
}

RESOURCES += \
    YTPlayer.qrc

mcc_data.target = mcc-data
mcc_data.commands = \
    $$top_srcdir/scripts/mcc-data-util.py \
        --keyfile=$$top_srcdir/youtube-data-api-v3.key \
        --mccfile=$$top_srcdir/resources/mcc-data.json \
        --verbose --mode check

QMAKE_EXTRA_TARGETS += mcc-data
PRE_TARGETDEPS += mcc-data

