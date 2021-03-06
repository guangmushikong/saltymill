include: [ osm.get_data ]

#TODO: Replace all this with a simpler call to update-osrm.sh. Tricky thing is to make that happen in the background while
# the rest of the install continues. Or even better, delayed by a few minutes.

{% for instance in pillar.tm_osrminstances %}
osrm_update_{{instance.profile}}:
  file.symlink:
    - name: {{ pillar.tm_osrmdir }}/{{ instance.profile }}/extract.osm.pbf
    - target: {{ pillar.tm_dir }}/extract.osm.pbf
    - require: [ cmd: update_data ]

# So that it will re-run if the indexing fails.
osrm_missingindex_{{instance.profile}}:
  cmd.run:
    - name: ''
    - unless: test -f {{ pillar.tm_osrmdir }}/{{ instance.profile}}/extract.osrm.hsgr

osrm_start_{{instance.profile}}:
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'Building OSRM index for {{instance.name}}...'"
    - onlyif: test -f {{pillar.tm_osrmdir}}/{{ instance.profile }}/osrm-routed 
    - watch: [ file: osrm_update_{{instance.profile}}, cmd: osrm_missingindex_{{instance.profile}} ] 

osrm_reindex_{{instance.profile}}:
  cmd.wait:
    - cwd: {{pillar.tm_osrmdir}}/{{instance.profile}}
    - name: |
        ./osrm-extract extract.osm.pbf # creates .names, ., .restrictions
        ./osrm-prepare extract.osrm # creates .fileIndex, .hsgr, .nodes, .ramIndex, .edges
        sleep 2
        test -f extract.osrm.hsgr || ( echo "OSRM extract failed somehow." && exit 1 )
        pkill -f 'osrm-routed.*-p {{ instance.port }}' # Make sure we kill the right instance.
        # nohup ./osrm-routed -p {{instance.port}} -t 8 extract.osrm > /dev/null 2>&1 & 
        {{ pillar.tm_dir}}/log.sh "OSRM index for profile '{{ instance.name}}' rebuilt."
        
    - watch: [ cmd: osrm_start_{{instance.profile}} ]
{% endfor %}