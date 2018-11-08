require 'bundler/setup'
require 'minitest/autorun'

require 'active_record'
require 'active_admin/subnav'
require 'sass-rails'

class Minitest::SharedExamples < Module
  include Minitest::Spec::DSL
end

ResourceMenuSpec = Minitest::SharedExamples.new do
  it "to have sub navigation menu name accessor" do
    assert_respond_to resource, :sub_navigation_menu_name
    assert_respond_to resource, :sub_navigation_menu_name=
  end

  it "is a sub menu item when sub_navigation_menu_name is set" do
    refute resource.sub_menu_item?
    resource.sub_navigation_menu_name = "Dashboard"
    assert resource.sub_menu_item?
  end
end

describe "activeadmin-subnav" do
  it "registers a sub navigation view" do
    assert_equal ActiveAdmin::Views::TabbedNavigation, ActiveAdmin::ViewFactory.new.default_for(:sub_navigation)
  end

  it "registers a header with subn navigation" do
    assert_equal ActiveAdmin::Views::HeaderWithSubnav, ActiveAdmin::ViewFactory.new.default_for(:header)
  end

  def namespace
    app = ActiveAdmin::Application.new
    app.namespace(:admin)
  end

  describe "extends ActiveAdmin::Namespace" do
    it "adds sub menus" do
      assert_respond_to namespace, :sub_menus
    end
  end

  describe "extends Page" do
    let(:page) { ActiveAdmin::Page.new(namespace, "Dashboard", {}) }
    alias_method :resource, :page

    include ResourceMenuSpec

    it "to never show sub menus" do
      refute page.show_sub_menu?
    end
  end

  describe "extends Resource" do
    class Post; end
    let(:resource) { ActiveAdmin::Resource.new(namespace, Post) }

    include ResourceMenuSpec

    it "to assign nested resources" do
      resource.nested_resources = "nested"
      assert_equal "nested", resource.has_nested_resources?
    end
  end
end
