require 'spec_helper'

describe "StaticPages" do
  let (:websitename) {"Ruby on Rails Tutorial Sample App"}

   describe "Home page" do
    before { visit root_path }
    subject { page }
      it { should have_selector('h1', text: 'Sample App') }
      it { should have_selector('h1', text: 'Sample App') }
      it { should have_selector 'title',
                          text: "Ruby on Rails Tutorial Sample App" }
      it { should have_selector('title', text: full_title('')) }
    end


  describe  "Help page" do
     it "should have the h1 'Help'" do
    visit help_path
    page.should have_selector('h1', :text => 'Help')
    end

     it "should have the title 'Help'" do
    visit help_path
    page.should have_selector('title',
                      :text => full_title('Help'))
    end
  end


  describe "About page" do
   it "should have the h1 'About Us'" do
    visit about_path
    page.should have_selector('h1', :text => 'About Us')
  end
  it "should have the title 'About Us'" do
    visit about_path
    page.should have_selector('title',
                    :text =>  full_title('About Us') )
    end
  end

 describe  "Contact page" do
     it "should have the h1 'Contact'" do
    visit contact_path
    page.should have_selector('h1', :text => 'Contact')
    end

     it "should have the title 'Contact'" do
    visit contact_path
    page.should have_selector('title',
                      :text => full_title('Contact'))
    end
  end


end
