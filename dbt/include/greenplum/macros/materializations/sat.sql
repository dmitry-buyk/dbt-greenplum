{% macro greenplum__get_sat_sql(target, source_sql) -%} 

    {%- set load_key = config.get('load_key', '') -%}
    {%- set workflow_id = get_dataflow_id() -%}
    {%- set preprocess_flg = config.get('preprocess_flg', 'True') -%}
    {%- set version_type_flg = config.get('version_type_flg', 'True' ) -%}
    {%- set eff_from = config.get('eff_from', '') -%}
    {%- set delete_flg = config.get('delete_flg', 'True') -%}
    {%- set gen_1970_flg = config.get('gen_1970_flg', 'False') -%}
    {%- set value_partition_flg = config.get('value_partition_flg', 'True') -%}
    {%- set distribution_key = config.get('distribution_key', '') -%}
    {%- set reaction_to_double_code = config.get('reaction_to_double_code', 2 ) -%}

    {%- set dml -%}
    select dwh_meta.sat_loader('{{ source_sql.schema ~ "." ~ source_sql.identifier }}' ,
                                        '{{ target.schema ~ "." ~ target.identifier }}' ,
                                        '{{ load_key }}' ,
                                        '{{ workflow_id }}' ,
                                        {{ preprocess_flg }} ,
                                        {{ version_type_flg }} ,
                                        '{{ eff_from }}' ,
                                        {{ delete_flg }} ,
                                        {{ gen_1970_flg }}
                                         )
    {%- endset -%}

    {% do return(dml) %}

{% endmacro %}