# curl a kml list of narm museums and convert it to geojson. Strip some
# presentational properties with `jq`.
#
# togeojson:  `npm install -g togeojson`
# jq: http://stedolan.github.io/jq/
narm.geojson:
	curl -L 'https://mapsengine.google.com/map/kml?mid=zIPGfIU5JOj8.kcv-uCGATvaA&lid=zIPGfIU5JOj8.kG6lyMjYq-cs' \
	| togeojson \
	| jq '{type: "FeatureCollection", features: .features | map(del(.properties.styleUrl, .properties.styleHash))}' \
	> narm.geojson

# Pull the names of amrm museums from a spreadsheet.
#
# j: `npm install -g j`
# csvcut: http://csvkit.rtfd.org/
amrm-members.txt:
	j AMRM_Program\ Info\ Update_09.19.14_1.xls | csvcut -c1 | tail -n+4 \
	| grep -v '""' | sed 's/(as.*)//' > $@

# Take the museums from a line-delimited text file `members` and geocode each
# of them into a 'Feature'.  Wrap those features in a 'FeatureCollection' and
# we have geojson.
#
# geocode: `gem install geocode`
# sponge: `<package manager> install moreutils`
# jq: (above)
geocode-json:
	cat $(members) | while read museum; do \
		geocode -j -s nominatim "$$museum" | jq -c '.[0] | { \
			type: "Feature", \
			geometry: {type: "Point", coordinates: [.lon, .lat | tonumber]}, \
			properties: {name: .address.museum, address: .display_name} \
		}'; \
	done | sponge | jq -s '{type: "FeatureCollection", features: .}' > $$(basename $(members) -members.txt).geojson; \

amrm.geojson:
	make geocode-json members=amrm-members.txt

wrp.geojson:
	make geocode-json members=wrp-members.txt
