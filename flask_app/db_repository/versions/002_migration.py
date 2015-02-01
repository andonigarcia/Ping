from sqlalchemy import *
from migrate import *


from migrate.changeset import schema
pre_meta = MetaData()
post_meta = MetaData()
ping = Table('ping', post_meta,
    Column('id', Integer, primary_key=True, nullable=False),
    Column('message', String(length=150)),
    Column('timestamp', DateTime),
    Column('duration', DateTime),
    Column('company_id', Integer),
)

company = Table('company', post_meta,
    Column('id', Integer, primary_key=True, nullable=False),
    Column('name', String(length=150)),
    Column('address1', String(length=150)),
    Column('address2', String(length=150)),
    Column('city', String(length=150)),
    Column('state', String(length=2)),
    Column('zipcode', String(length=5)),
    Column('phone', String(length=10)),
    Column('email', String(length=150)),
    Column('password', String(length=50)),
    Column('timestamp', DateTime),
)


def upgrade(migrate_engine):
    # Upgrade operations go here. Don't create your own engine; bind
    # migrate_engine to your metadata
    pre_meta.bind = migrate_engine
    post_meta.bind = migrate_engine
    post_meta.tables['ping'].create()
    post_meta.tables['company'].columns['timestamp'].create()


def downgrade(migrate_engine):
    # Operations to reverse the above upgrade go here.
    pre_meta.bind = migrate_engine
    post_meta.bind = migrate_engine
    post_meta.tables['ping'].drop()
    post_meta.tables['company'].columns['timestamp'].drop()
