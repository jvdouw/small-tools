# Script for extending Etherpad

[Etherpad](https://github.com/ether/etherpad-lite) is a great, simple and intuitive tool for collaborative editing. It comes with an API that allows for easy extension, and that's exactly what we're doing here.

## export-pad.sh
_Export Pad_ is a script that exports any pad to an HTML page, as well as a docx document. If you run it as a cronjob, you'll have your exports readily available at any given time, freshly exported from your etherpad.

It works by following roughly the following steps:
1. Retrieve the etherpad data using the Etherpad API (resulting in a JSON file)
2. Get the actual etherpad markdown contents from the appropriate JSON field, using `jq`.
3. Clean this up some more with `sed`
4. Export data to HTML and Docx with `pandoc` (note: I'm all for using ODT in stead of Docx, but in LibreOffice, the docx export looked significantly better than the ODT, strangely enough...)

### Installation instructions
At the top of the script, there is a _Configuration_ section. It allows you to define where results should go, set the Etherpad API key, what the name of the pad itself is, and to set the language of the export date and time that will be added to your exports.
