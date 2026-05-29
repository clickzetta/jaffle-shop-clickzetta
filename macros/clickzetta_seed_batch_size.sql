{% macro clickzetta__get_batch_size() %}
  {{ return(1000) }}
{% endmacro %}


{% macro clickzetta__load_csv_rows(model, agate_table) %}

  {% set batch_size = get_batch_size() %}
  {% set column_override = model['config'].get('column_types', {}) %}
  {% set datetime_types = ['timestamp', 'date', 'time'] %}
  {% set string_types = ['string', 'text', 'varchar'] %}

  {# Pre-compute column types once, outside all loops #}
  {% set col_types = [] %}
  {% for col_name in agate_table.column_names %}
    {%- set inferred = adapter.convert_type(agate_table, loop.index0) -%}
    {%- set resolved = column_override.get(col_name, inferred) -%}
    {%- do col_types.append(resolved) -%}
  {% endfor %}

  {% set statements = [] %}

  {% for chunk in agate_table.rows | batch(batch_size) %}

    {% set sql %}
      insert into {{ this.render() }} values
      {% for row in chunk -%}
        ({%- for i in range(col_types | length) -%}
          {%- set type = col_types[i] -%}
          {%- set val = row[i] -%}
          {%- if val is none or val == '' -%}
            NULL
          {%- elif type | lower in datetime_types -%}
            {{ type | upper }} '{{ val }}'
          {%- elif type | lower in string_types -%}
            '{{ val | replace("'", "''") }}'
          {%- else -%}
            cast('{{ val }}' as {{ type }})
          {%- endif -%}
          {%- if not loop.last %},{%- endif %}
        {%- endfor -%})
        {%- if not loop.last %},{%- endif %}
      {%- endfor %}
    {% endset %}

    {% do adapter.add_query(sql, abridge_sql_log=True) %}

    {% if loop.index0 == 0 %}
      {% do statements.append(sql) %}
    {% endif %}
  {% endfor %}

  {{ return(statements[0]) }}
{% endmacro %}
