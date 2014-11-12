narm.geojson:
	curl -L 'https://mapsengine.google.com/map/kml?mid=zIPGfIU5JOj8.kcv-uCGATvaA&lid=zIPGfIU5JOj8.kG6lyMjYq-cs' \
	| togeojson \
	| jq '{type: "FeatureCollection", features: .features | map(del(.properties.styleUrl, .properties.styleHash))}' \
	> narm.geojson

amrm-members.txt:
	j AMRM_Program\ Info\ Update_09.19.14_1.xls | csvcut -c1 | tail -n+4 \
	| grep -v '""' | sed 's/(as.*)//' > $@

amrm.geojson: amrm-members.txt
	@cat $< | while read museum; do \
		geocode -j -s nominatim "$$museum" | jq -c '.[0] | { \
			type: "Feature", \
			geometry: {type: "Point", coordinates: [.lon, .lat | tonumber]}, \
			properties: {name: .address.museum, address: .display_name} \
		}'; \
	done | sponge | jq -s '{type: "FeatureCollection", features: .}' > amrm.geojson
