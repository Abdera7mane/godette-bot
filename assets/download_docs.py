import requests
import zipfile
import io
import re

archive = "https://github.com/godotengine/godot/archive/refs/heads/%s.zip"

godot_3 = archive % "3.x"
godot_4 = archive % "master"

session = requests.Session()

pattern = re.compile("(doc|modules).+\.xml")

def download_archive(url):
    print("Downloading:", url)
    response = session.get(url)
    print("Extracting files")
    count = 0
    with zipfile.ZipFile(io.BytesIO(response.content)) as zip_file:
        for info in zip_file.infolist():
            if pattern.search(info.filename):
                zip_file.extract(info, "documentation")
                count += 1
    print("Extracted %d files" % count)

download_archive(godot_3)
download_archive(godot_4)

print("Done")