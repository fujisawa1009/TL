CSV.open('/tmp/enreq8030.csv', 'w') do |fd|
    fd << ["受注ID", "定期受注ID", "(更新前)通信欄", "(更新後)通信欄", "(更新前)定期受注備考1", "(更新後)定期受注備考1", "エラー"]
    Order.where.not(remark: nil).where.not(remark: "").find_each do |order|
      subs_order = order.subs_order
      # 定期受注備考1の更新処理
      before_memo01 = subs_order.memo01
      after_memo01 = before_memo01 ? subs_order.memo01 + order.remark : order.remark
      # subs_order.update(memo01: after_memo01)
      # 通信欄更新処理
      before_remark = order.remark
      # order.update(remark: nil)
      # before afterの出力
      fd << [order.id, subs_order.id, before_remark, order.remark, before_memo01, after_memo01]
    rescue StandardError => e
      fd << [order&.id, subs_order&.id, before_remark, order&.remark, before_memo01, after_memo01, e]
    end
  end