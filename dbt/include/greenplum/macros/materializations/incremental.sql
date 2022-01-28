{% macro dbt_greenplum_validate_get_incremental_strategy(config) %}
  {#-- Find and validate the incremental strategy #}
  {%- set strategy = config.get("incremental_strategy", default="scd1") -%}

  {% set invalid_strategy_msg -%}
    Invalid incremental strategy provided: {{ strategy }}
    Expected one of: 'scd1', 'sat', 'pit'
  {%- endset %}
  {% if strategy not in ['scd1', 'sat', 'pit'] %}
    {% do exceptions.raise_compiler_error(invalid_strategy_msg) %}
  {% endif %}
  {% do return(strategy) %}
{% endmacro %}

{% macro dbt_greenplum_get_incremental_sql(strategy, tmp_relation, target_relation) %}
  {% if strategy == 'scd1' %}
    {% do return(greenplum__get_scd1_sql(target_relation, tmp_relation)) %}
  {% elif strategy == 'sat' %}
    {% do return(greenplum__get_sat_sql(target_relation, tmp_relation)) %}
  {% elif strategy == 'pit' %}
    {% do return(greenplum__get_pit_sql(target_relation, tmp_relation)) %}
  {% else %}
    {% do exceptions.raise_compiler_error('invalid strategy: ' ~ strategy) %}
  {% endif %}
{% endmacro %}


{% materialization incremental, adapter='greenplum' -%}
  {% set target_relation = this %}
  {% set existing_relation = load_relation(this) %}
  {% set tmp_relation = make_temp_relation(this) %}

  {#-- Validate early so we don't run SQL if the strategy is invalid --#}
  {% set strategy = dbt_greenplum_validate_get_incremental_strategy(config) -%}
 
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  {% if existing_relation is none %}
    {% do run_query(create_table_as(True, tmp_relation, sql)) %}
    {% do run_query(greenplum__create_target_table(tmp_relation, target_relation)) %}
    {% set build_sql = dbt_greenplum_get_incremental_sql(strategy, tmp_relation, target_relation) %}     
  {% elif existing_relation.is_view %}
    {#-- Can't overwrite a view with a table - we must drop --#}
    {{ log("Dropping relation " ~ target_relation ~ " because it is a view and this model is a table.") }}
    {% do adapter.drop_relation(existing_relation) %}
    {% set build_sql = create_table_as(False, target_relation, sql) %} 
  {% elif strategy == 'pit' %}
    {% set build_sql = sql %}
  {% else %}
    {% do run_query(create_table_as(True, tmp_relation, sql)) %}
    {% set build_sql = dbt_greenplum_get_incremental_sql(strategy, tmp_relation, target_relation) %}  
  {% endif %}

  {%- call statement('main') -%}
    {{ build_sql }}
  {%- endcall -%}

  {{ run_hooks(post_hooks, inside_transaction=True) }}

  {% do adapter.commit() %}

  {% set target_relation = target_relation.incorporate(type='table') %}
  {% do persist_docs(target_relation, model) %}

  {{ return({'relations': [target_relation]}) }}

{%- endmaterialization %}