require 'kconv'
require 'nokogiri'

class FParser
  TOTAL_ITEMS = %w(給与口座振込額 支給額合計 控除額合計 賞与口座振込額)
  INCOME_ITEMS = %w(本給 グレード給 コンピテンシ給 時間外手当 京浜地域手当 通勤費補助 持株会奨励金 4月分初任給 4月分精算額 5月遡及額 福利厚生P課税 持株手数料支給 基本分 成果分 定額 寸志)
  DEDUCTION_ITEMS = %w(所得税 住民税 年金保険料 個人拠出年金分 基本健康保険料 特定健康保険料 雇用保険料 寮費 団体定期保険 団体損害保険 従業員持株会 （内奨励金分 通勤費 労働組合費 労金等控除金 食事代 その他の控除 後援会費 （うち遡及額 持株手数料控除 手帳カレンダー)
  ATTENDANCE_ITEMS = %w(所定内出勤 年次休暇 年次半日休暇 普通時間外H 準欠勤回数 準欠勤H)

  def self.parse(path)
    doc = get_doc(path)

    is_bonus = is_bonus?(doc)
    selectors = css_selectors(is_bonus)

    year, month = /(?<y>\d{4})年 ?(?<m>\d{1,2})月/.match(
      doc.at_css(selectors[:year_and_month]).text.to_half_width
    ).values_at(:y, :m)

    # 表の各項目（総額、支給、控除、勤怠）をパース
    item_array = []
    range = is_bonus ? (1..-2) : (0..-1) # ボーナスの明細では最初（日付）と最後（年金番号）を除外
    doc.css(selectors[:items])[range].map { |a| a.text.split(' ') }.flatten.each do |item|
      break if item == '下' # 「下記のとおり、ご通知申し上げます。」以降は無視
      item_array << item.to_half_width.trim_space.delete('，')
    end
    items = Hash[*item_array]

    results = {
      year: year,
      month: month,
      is_bonus: is_bonus,
      total: items.select { |k, _| TOTAL_ITEMS.include?(k) },
      income: items.select { |k, _| INCOME_ITEMS.include?(k) },
      deduction: items.select { |k, _| DEDUCTION_ITEMS.include?(k) },
      attendance:  items.select { |k, _| ATTENDANCE_ITEMS.include?(k) },
      other: items.reject { |k, _| (TOTAL_ITEMS + INCOME_ITEMS + DEDUCTION_ITEMS + ATTENDANCE_ITEMS).include?(k) }
    }
    results.delete(:other) if results[:other].empty?
    results.delete(:attendance) if is_bonus

    results
  end

  private

  def self.get_doc(path)
    html = File.read(path)
    Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')
  end

  def self.css_selectors(is_bonus)
    if is_bonus
      {
        year_and_month: 'p.ft03',
        items: 'p.ft02'
      }
    else
      {
        year_and_month: 'p.ft02',
        items: 'p.ft04'
      }
    end
  end

  def self.is_bonus?(doc)
    doc.css('p').any? { |t| t.text.include?('賞与支払明細書') || t.text.include?('寸志支払明細書') }
  end
end

class String
  def to_half_width
    self.tr('ａ-ｚＡ-Ｚ０-９．', 'a-zA-Z0-9.')
  end

  def trim_space
    self.gsub(/[[:space:]]/, '')
  end
end

