module ArticlesHelper

  def distance_to_icon(distance)
    if distance < 140
      image_tag("icons/thermometer-high.svg", title: "Document has high relevance regarding your search")
    elsif distance < 145
      image_tag("icons/thermometer-half.svg", title: "Document has only medium relevance regarding your search")
    else
      image_tag("icons/thermometer-low.svg", title: "Document has only little relevance regarding your search")
    end
  end

end
