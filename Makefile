VERSION=0.1.2
NAME=SkyrimNet_Arousal

RELEASE_FILE=versions/${NAME} ${VERSION}.zip

release: 
	python3 ./python_scripts/fomod-info.py -v ${VERSION} -n '${NAME}' -o fomod/info.xml fomod-source/info.xml
	if exist '${RELEASE_file}' rm /Q /S '${RELEASE_FILE}'
	7z -r a '${RELEASE_FILE}' fomod \
	    Scripts \
		README.md \
		${NAME}.esp \
		fomod/info.json \
		SKSE/Plugins/SkyrimNet