{% macro greenplum__get_scd1_sql(target, source_sql, unique_key, dest_columns, predicates) -%}

    {%- set dest_cols_csv = get_quoted_csv(dest_columns | map(attribute='name')) -%}
    {%- set sql_header = config.get('sql_header', none) -%}

    {%- set dml -%}
    {%- if unique_key is none -%}

        {{ sql_header if sql_header is not none }}

        insert into {{ target }} ({{ dest_cols_csv }})
        (
            select {{ dest_cols_csv }}
            from {{ source_sql }}
        )

    {%- else -%}

        select dwh_meta.srv_scd1_loader('{{ source_sql }}' ,
                                        '{{ target.schema ~ "." ~ target.identifier }}' ,
                                        '{{ unique_key }}' ,
                                        'U' ,
                                        'test_dbt_scd' ,
                                        '' ,
                                        True ,
                                        false ,
                                        True ,
                                        '' ,
                                        false ,
                                        '{{ unique_key }}' ,
                                        1 )
        

    {%- endif -%}
    {%- endset -%}
    
    {% do return(dml) %}

{% endmacro %}