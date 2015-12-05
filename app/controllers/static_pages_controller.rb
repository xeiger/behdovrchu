# encoding: utf-8
class StaticPagesController < ApplicationController

  layout 'application'

  def home
    render layout: 'welcome'
  end

  def programme
  end

  def results
  end

  def gallery
  end

end