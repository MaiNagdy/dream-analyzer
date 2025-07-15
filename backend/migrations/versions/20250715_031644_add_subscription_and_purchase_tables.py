"""Add subscription and purchase tables

Revision ID: 20250715_031644
Revises: 
Create Date: 2025-07-15 03:16:44.195458

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '20250715_031644'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # Create users table
    op.create_table('users',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('email', sa.String(length=255), nullable=False),
        sa.Column('username', sa.String(length=100), nullable=False),
        sa.Column('password_hash', sa.String(length=255), nullable=False),
        sa.Column('first_name', sa.String(length=100), nullable=True),
        sa.Column('last_name', sa.String(length=100), nullable=True),
        sa.Column('phone_number', sa.String(length=20), nullable=True),
        sa.Column('date_of_birth', sa.Date(), nullable=True),
        sa.Column('gender', sa.String(length=20), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=False),
        sa.Column('email_verified', sa.Boolean(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('updated_at', sa.DateTime(), nullable=False),
        sa.Column('last_login', sa.DateTime(), nullable=True),
        sa.Column('credits', sa.Integer(), nullable=False),
        sa.Column('subscription_status', sa.String(length=20), nullable=False),
        sa.Column('subscription_type', sa.String(length=50), nullable=True),
        sa.Column('subscription_start_date', sa.DateTime(), nullable=True),
        sa.Column('subscription_end_date', sa.DateTime(), nullable=True),
        sa.Column('subscription_auto_renew', sa.Boolean(), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_users_email'), 'users', ['email'], unique=True)
    op.create_index(op.f('ix_users_username'), 'users', ['username'], unique=True)
    op.create_index(op.f('ix_users_phone_number'), 'users', ['phone_number'], unique=True)

    # Create dream_analyses table
    op.create_table('dream_analyses',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('user_id', sa.String(length=36), nullable=False),
        sa.Column('dream_description', sa.Text(), nullable=False),
        sa.Column('analysis_result', sa.Text(), nullable=True),
        sa.Column('mood_before', sa.String(length=50), nullable=True),
        sa.Column('mood_after', sa.String(length=50), nullable=True),
        sa.Column('symbols_identified', sa.Text(), nullable=True),
        sa.Column('themes_identified', sa.Text(), nullable=True),
        sa.Column('interpretation', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('updated_at', sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_dream_analyses_user_id'), 'dream_analyses', ['user_id'], unique=False)

    # Create purchases table
    op.create_table('purchases',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('user_id', sa.String(length=36), nullable=False),
        sa.Column('product_id', sa.String(length=100), nullable=False),
        sa.Column('purchase_token', sa.String(length=500), nullable=False),
        sa.Column('order_id', sa.String(length=100), nullable=True),
        sa.Column('purchase_time', sa.DateTime(), nullable=False),
        sa.Column('purchase_state', sa.Integer(), nullable=False),
        sa.Column('consumption_state', sa.Integer(), nullable=False),
        sa.Column('acknowledgement_state', sa.Integer(), nullable=False),
        sa.Column('credits_granted', sa.Integer(), nullable=False),
        sa.Column('is_subscription', sa.Boolean(), nullable=False),
        sa.Column('subscription_period_start', sa.DateTime(), nullable=True),
        sa.Column('subscription_period_end', sa.DateTime(), nullable=True),
        sa.Column('auto_renewing', sa.Boolean(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('updated_at', sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_purchases_user_id'), 'purchases', ['user_id'], unique=False)
    op.create_index(op.f('ix_purchases_purchase_token'), 'purchases', ['purchase_token'], unique=True)

    # Create user_sessions table
    op.create_table('user_sessions',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('user_id', sa.String(length=36), nullable=False),
        sa.Column('session_token', sa.String(length=255), nullable=False),
        sa.Column('expires_at', sa.DateTime(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('is_active', sa.Boolean(), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_user_sessions_user_id'), 'user_sessions', ['user_id'], unique=False)
    op.create_index(op.f('ix_user_sessions_session_token'), 'user_sessions', ['session_token'], unique=True)

    # Create api_usage table
    op.create_table('api_usage',
        sa.Column('id', sa.String(length=36), nullable=False),
        sa.Column('user_id', sa.String(length=36), nullable=False),
        sa.Column('endpoint', sa.String(length=100), nullable=False),
        sa.Column('tokens_used', sa.Integer(), nullable=True),
        sa.Column('cost', sa.Numeric(precision=10, scale=6), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_api_usage_user_id'), 'api_usage', ['user_id'], unique=False)


def downgrade():
    # Drop tables in reverse order
    op.drop_table('api_usage')
    op.drop_table('user_sessions')
    op.drop_table('purchases')
    op.drop_table('dream_analyses')
    op.drop_table('users')
