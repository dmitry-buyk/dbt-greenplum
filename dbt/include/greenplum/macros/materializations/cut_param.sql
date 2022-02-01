{% macro get_cut_param(source_schema, source_table) -%}
    {%- set full_source_table_name = source(source_schema, source_table) -%}
    dwh_meta.dbt_get_cut_parm('{{ this }}', '{{ full_source_table_name }}')
{%- endmacro %}
{% macro get_cut_param_filter(source_schema, source_table, param_name='dataflow_dttm') -%}
    {% if  param_name == 'dataflow_dttm' -%}
        {{ param_name }} > (select {{ get_cut_param(source_schema, source_table) }}::timestamp without time zone)
    {%- else -%}
        {{ param_name }} > (select {{ get_cut_param(source_schema, source_table) }} )
    {%- endif %}
{%- endmacro %}
{% macro set_cut_param(source_schema, source_table, param_name='dataflow_dttm') %}
    {% set full_source_table_name = source(source_schema, source_table) %}
    {% set sttmnt = "select dwh_meta.dbt_upd_cut_parm('" ~ this  ~ "', '" ~ source(source_schema, source_table) ~ "', '" ~ param_name ~ "')" %}
    {{ return (sttmnt) }}
{% endmacro %}
{% macro set_cut_params(source_list, param_name='dataflow_dttm') -%}
    {% for source_schema, source_table in source_list -%}
        {{ set_cut_param(source_schema, source_table, param_name) -}}
        {{ ";" if not loop.last }}
    {% endfor %}
{%- endmacro %}