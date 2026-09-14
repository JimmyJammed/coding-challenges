# Troubleshooting

No internet: all tabs work in the default offline mode. Live URL failures are expected without connectivity. A 405 or 501 response means HEAD is unsupported. A redirect is followed by URLSession; HTTP status does not prove a site's content is trustworthy.

No saved history: save a result explicitly; reinstalling/resetting the simulator may remove app data. File decoding/permission errors surface in the app. Do not silently delete an unreadable file.

Project changes: project.yml is the XcodeGen source; regenerate with `xcodegen generate`. The generated project is committed, so XcodeGen is not required to run the demo.
