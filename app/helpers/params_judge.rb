# encoding:utf-8
class ParamsJudge

  # 传入页码数字是否有问题
  def self.page_judge(num)

    # 判断整形数
    if num.class != Integer
      if num.class != String
        return { :status => Const::LOG_REQUEST_NOT_LEGAL,  :msg => '传入的值不合法' }
      elsif num.match(/[^0-9]/)
        return { :status => Const::LOG_REQUEST_NOT_NUM,  :msg => '传入的值非整型数' }
      else
        tempNum = Integer(num);
      end
    else
      tempNum = num
    end

    # 当传入的页码小于等于0
    if tempNum <= 0
      return { :status => Const::LOG_REQUEST_NOT_POSITIVE_NUMBER,  :msg => '传入的值非正数' }
    else
      return {}
    end

  end





end
