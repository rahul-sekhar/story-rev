class AccountProfitShares < ActiveRecord::Migration
  def up
    change_table :config_data do |t|
      t.datetime :profit_share_date, null: false, default: DateTime.now
    end
  end

  def down
    change_table :config_data do |t|
      t.remove :profit_share_date
    end
  end
end
