{% macro get_dataflow_id() -%}
  {%set dataflow_id = 'dbt__' ~ invocation_id%}
  {{ return (dataflow_id)}}    
{%- endmacro %}

{% macro greenplum__get_scd1_sql(target, source_sql, unique_key) -%} 

    {%- set load_key = config.get('load_key', '') -%}
    {%- set load_type = config.get('load_type', 'U') -%}
    {%- set workflow_id = get_dataflow_id() -%}
    {%- set partition_column_nm = config.get('partition_column_nm', '') -%}
    {%- set reaction_to_null_flg = config.get('reaction_to_null_flg', 'True' ) -%}
    {%- set reaction_to_empty_source_flg = config.get('reaction_to_empty_source_flg', 'False') -%}
    {%- set compare_all_field_flg = config.get('compare_all_field_flg', 'True') -%}
    {%- set fields_for_compare = config.get('fields_for_compare', '') -%}
    {%- set value_partition_flg = config.get('value_partition_flg', 'True') -%}
    {%- set distribution_key = config.get('distribution_key', '') -%}
    {%- set reaction_to_double_code = config.get('reaction_to_double_code', 2 ) -%}

    {%- set dml -%}
    select dwh_meta.srv_scd1_loader('{{ source_sql.schema ~ "." ~ source_sql.identifier }}' ,
                                        '{{ target.schema ~ "." ~ target.identifier }}' ,
                                        '{{ load_key }}' ,
                                        '{{ load_type }}' ,
                                        '{{ workflow_id }}' ,
                                        '{{ partition_column_nm }}' ,
                                        {{ reaction_to_null_flg }} ,
                                        {{ reaction_to_empty_source_flg }} ,
                                        {{ compare_all_field_flg }} ,
                                        '{{ fields_for_compare }}' ,
                                        {{ value_partition_flg }} ,
                                        '{{ distribution_key }}' ,
                                        {{ reaction_to_double_code }}
                                         )
    {%- endset -%}

    {% do return(dml) %}

{% endmacro %}