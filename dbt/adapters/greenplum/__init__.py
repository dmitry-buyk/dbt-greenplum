# these are mostly just exports, #noqa them so flake8 will be happy
from dbt.adapters.greenplum.connections import GreenplumConnectionManager  # noqa
from dbt.adapters.greenplum.connections import GreenplumCredentials
from dbt.adapters.greenplum.relation import GreenplumColumn  # noqa
from dbt.adapters.greenplum.relation import GreenplumRelation  # noqa: F401
from dbt.adapters.greenplum.impl import GreenplumAdapter

from dbt.adapters.base import AdapterPlugin
from dbt.include import greenplum

Plugin = AdapterPlugin(
    adapter=GreenplumAdapter,
    credentials=GreenplumCredentials,
    include_path=greenplum.PACKAGE_PATH)
