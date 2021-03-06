require File.dirname(__FILE__) + '/spec_helper'

describe MetaTags do
  before :each do
    @view = ActionView::Base.new
  end
  
  describe 'loading' do
    it 'should be mixed into ActionView::Base' do
      ActionView::Base.included_modules.should include(MetaTags)
    end
    
    it 'should respond to "title" helper' do
      @view.should respond_to(:title)
    end
    
    it 'should respond to "description" helper' do
      @view.should respond_to(:description)
    end
    
    it 'should respond to "keywords" helper' do
      @view.should respond_to(:keywords)
    end

    it 'should respond to "noindex" helper' do
      @view.should respond_to(:noindex)
    end


    it 'should respond to "set_meta_tags" helper' do
      @view.should respond_to(:set_meta_tags)
    end

    it 'should respond to "display_meta_tags" helper' do
      @view.should respond_to(:display_meta_tags)
    end
  end
  
  describe 'returning values' do
    it 'should return title' do
      @view.title('someTitle').should == 'someTitle'
    end

    it 'should return headline if specified' do
      @view.title('someTitle', 'someHeadline').should == 'someHeadline'
    end
    
    it 'should return description' do
      @view.description('someDescription').should == 'someDescription'
    end

    it 'should return keywords' do
      @view.keywords('someKeywords').should == 'someKeywords'
    end

    it 'should return noindex' do
      @view.noindex('someNoindex').should == 'someNoindex'
    end
  end
  
  describe 'displaying title' do
    it 'should use website name if title is empty' do
      @view.display_meta_tags(:site => 'someSite').should == '<title>someSite</title>'
    end
    
    it 'should display title when "title" used' do
      @view.title('someTitle')
      @view.display_meta_tags(:site => 'someSite').should == '<title>someSite | someTitle</title>'
    end

    it 'should display title when "set_meta_tags" used' do
      @view.set_meta_tags(:title => 'someTitle')
      @view.display_meta_tags(:site => 'someSite').should == '<title>someSite | someTitle</title>'
    end

    it 'should display custom title if given' do
      @view.title('someTitle')
      @view.display_meta_tags(:site => 'someSite', :title => 'defaultTitle').should == '<title>someSite | someTitle</title>'
    end

    it 'should use website before page by default' do
      @view.display_meta_tags(:site => 'someSite', :title => 'someTitle').should == '<title>someSite | someTitle</title>'
    end

    it 'should only use markup in titles in the view' do
      @view.title('<b>someTitle</b>').should == '<b>someTitle</b>'
      @view.display_meta_tags(:site => 'someSite').should == '<title>someSite | someTitle</title>'
    end

    it 'should use page before website if :reverse' do
      @view.display_meta_tags(:site => 'someSite', :title => 'someTitle', :reverse => true).should == '<title>someTitle | someSite</title>'
    end

    it 'should be lowercase if :lowercase' do
      @view.display_meta_tags(:site => 'someSite', :title => 'someTitle', :lowercase => true).should == '<title>someSite | sometitle</title>'
    end

    it 'should use custom separator if :separator' do
      @view.title('someTitle')
      @view.display_meta_tags(:site => 'someSite', :separator => '-').should == '<title>someSite - someTitle</title>'
      @view.display_meta_tags(:site => 'someSite', :separator => ':').should == '<title>someSite : someTitle</title>'
      @view.display_meta_tags(:site => 'someSite', :separator => '&mdash;').should == '<title>someSite &mdash; someTitle</title>'
    end

    it 'should use custom prefix and suffix if available' do
      @view.display_meta_tags(:site => 'someSite', :title => 'someTitle', :prefix => ' -', :suffix => '- ').should == '<title>someSite -|- someTitle</title>'
    end

    it 'should collapse prefix if false' do
      @view.display_meta_tags(:site => 'someSite', :title => 'someTitle', :prefix => false).should == '<title>someSite| someTitle</title>'
    end

    it 'should collapse suffix if false' do
      @view.display_meta_tags(:site => 'someSite', :title => 'someTitle', :suffix => false).should == '<title>someSite |someTitle</title>'
    end

    it 'should use all custom options if available' do
      @view.display_meta_tags(:site => 'someSite',
                              :title => 'someTitle',
                              :prefix => ' -',
                              :suffix => '+ ',
                              :separator => ':',
                              :lowercase => true,
                              :reverse => true).should == '<title>sometitle -:+ someSite</title>'
    end
    
    it 'shold allow Arrays in title' do
      @view.display_meta_tags(:site => 'someSite', :title => ['someTitle', 'anotherTitle']).should == '<title>someSite | someTitle | anotherTitle</title>'
    end

    it 'shold build title in reverse order if :reverse' do
      @view.display_meta_tags(:site => 'someSite',
                              :title => ['someTitle', 'anotherTitle'],
                              :prefix => ' -',
                              :suffix => '+ ',
                              :separator => ':',
                              :reverse => true).should == '<title>anotherTitle -:+ someTitle -:+ someSite</title>'
    end
  end
  
  describe 'displaying description' do
    it 'should display description when "description" used' do
      @view.description('someDescription')
      @view.display_meta_tags(:site => 'someSite').should include('<meta content="someDescription" name="description" />')
    end

    it 'should display description when "set_meta_tags" used' do
      @view.set_meta_tags(:description => 'someDescription')
      @view.display_meta_tags(:site => 'someSite').should include('<meta content="someDescription" name="description" />')
    end

    it 'should display default description' do
      @view.display_meta_tags(:site => 'someSite', :description => 'someDescription').should include('<meta content="someDescription" name="description" />')
    end

    it 'should use custom description if given' do
      @view.description('someDescription')
      @view.display_meta_tags(:site => 'someSite', :description => 'defaultDescription').should include('<meta content="someDescription" name="description" />')
    end

    it 'should strip multiple spaces' do
      @view.display_meta_tags(:site => 'someSite', :description => "some \n\r\t description").should include('<meta content="some description" name="description" />')
    end

    it 'should strip HTML' do
      @view.display_meta_tags(:site => 'someSite', :description => "<p>some <b>description</b></p>").should include('<meta content="some description" name="description" />')
    end
  end
  
  describe 'displaying keywords' do
    it 'should display keywords when "keywords" used' do
      @view.keywords('some-keywords')
      @view.display_meta_tags(:site => 'someSite').should include('<meta content="some-keywords" name="keywords" />')
    end

    it 'should display keywords when "set_meta_tags" used' do
      @view.set_meta_tags(:keywords => 'some-keywords')
      @view.display_meta_tags(:site => 'someSite').should include('<meta content="some-keywords" name="keywords" />')
    end

    it 'should display default keywords' do
      @view.display_meta_tags(:site => 'someSite', :keywords => 'some-keywords').should include('<meta content="some-keywords" name="keywords" />')
    end

    it 'should use custom keywords if given' do
      @view.keywords('some-keywords')
      @view.display_meta_tags(:site => 'someSite', :keywords => 'default_keywords').should include('<meta content="some-keywords" name="keywords" />')
    end

    it 'should lowercase keywords' do
      @view.display_meta_tags(:site => 'someSite', :keywords => 'someKeywords').should include('<meta content="somekeywords" name="keywords" />')
    end

    it 'should join keywords from Array' do
      @view.display_meta_tags(:site => 'someSite', :keywords => %w(keyword1 keyword2)).should include('<meta content="keyword1, keyword2" name="keywords" />')
    end

    it 'should join keywords from nested Arrays' do
      @view.display_meta_tags(:site => 'someSite', :keywords => [%w(keyword1 keyword2), 'keyword3']).should include('<meta content="keyword1, keyword2, keyword3" name="keywords" />')
    end
  end
  
  describe 'displaying noindex' do
    it 'should display noindex when "noindex" used' do
      @view.noindex( true )
      @view.display_meta_tags(:site => 'someSite').should include('<meta content="noindex" name="robots" />')
    end

    it 'should display noindex when "set_meta_tags" used' do
      @view.set_meta_tags(:noindex => true)
      @view.display_meta_tags(:site => 'someSite').should include('<meta content="noindex" name="robots" />')
    end

    it 'should use custom noindex if given' do
      @view.noindex( 'some-noindex' )
      @view.display_meta_tags(:site => 'someSite').should include('<meta content="noindex" name="some-noindex" />')
    end

    it 'should display nothing by default' do
      @view.display_meta_tags(:site => 'someSite').should_not include('<meta content="noindex"')
    end
  end
  
end