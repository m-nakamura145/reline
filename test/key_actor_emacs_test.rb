require 'helper'

class Reline::KeyActor::Emacs::Test < Reline::TestCase
  def setup
    @prompt = '> '
    @line_editor = Reline::LineEditor.new(Reline::KeyActor::Emacs, @prompt)
    @line_editor.retrieve_completion_block = Reline.method(:retrieve_completion_block)
  end

  def test_ed_insert_one
    input_keys('a')
    assert_equal('a', @line_editor.line)
    assert_equal(1, @line_editor.instance_variable_get(:@byte_pointer))
  end

  def test_ed_insert_two
    input_keys('ab')
    assert_equal('ab', @line_editor.line)
    assert_equal(2, @line_editor.instance_variable_get(:@byte_pointer))
  end

  def test_ed_insert_mbchar_one
    input_keys('か')
    assert_equal('か', @line_editor.line)
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
  end

  def test_ed_insert_mbchar_two
    input_keys('かき')
    assert_equal('かき', @line_editor.line)
    assert_equal(6, @line_editor.instance_variable_get(:@byte_pointer))
  end

  def test_ed_insert_for_mbchar_by_plural_code_points
    input_keys("か\u3099")
    assert_equal("か\u3099", @line_editor.line)
    assert_equal(6, @line_editor.instance_variable_get(:@byte_pointer))
  end

  def test_ed_insert_for_plural_mbchar_by_plural_code_points
    input_keys("か\u3099き\u3099")
    assert_equal("か\u3099き\u3099", @line_editor.line)
    assert_equal(12, @line_editor.instance_variable_get(:@byte_pointer))
  end

  def test_move_next_and_prev
    input_keys('abd')
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(2, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(1, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-f")
    assert_equal(2, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys('c')
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('abcd', @line_editor.line)
  end

  def test_move_next_and_prev_for_mbchar
    input_keys('かきけ')
    assert_equal(9, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(6, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-f")
    assert_equal(6, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys('く')
    assert_equal(9, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('かきくけ', @line_editor.line)
  end

  def test_move_next_and_prev_for_mbchar_by_plural_code_points
    input_keys("か\u3099き\u3099け\u3099")
    assert_equal(18, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(12, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(6, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-f")
    assert_equal(12, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("く\u3099")
    assert_equal(18, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal("か\u3099き\u3099く\u3099け\u3099", @line_editor.line)
  end

  def test_move_to_beg_end
    input_keys('bcd')
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-a")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys('a')
    assert_equal(1, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-e")
    assert_equal(4, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys('e')
    assert_equal(5, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('abcde', @line_editor.line)
  end

  def test_ed_newline_with_cr
    input_keys('ab')
    assert_equal(2, @line_editor.instance_variable_get(:@byte_pointer))
    refute(@line_editor.finished?)
    input_keys("\C-m")
    assert_equal("ab\n", @line_editor.line)
    assert(@line_editor.finished?)
  end

  def test_ed_newline_with_lf
    input_keys('ab')
    assert_equal(2, @line_editor.instance_variable_get(:@byte_pointer))
    refute(@line_editor.finished?)
    input_keys("\C-j")
    assert_equal("ab\n", @line_editor.line)
    assert(@line_editor.finished?)
  end

  def test_em_delete_prev_char
    input_keys('ab')
    assert_equal(2, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-h")
    assert_equal(1, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('a', @line_editor.line)
  end

  def test_em_delete_prev_char_for_mbchar
    input_keys('かき')
    assert_equal(6, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-h")
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('か', @line_editor.line)
  end

  def test_em_delete_prev_char_for_mbchar_by_plural_code_points
    input_keys("か\u3099き\u3099")
    assert_equal(12, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-h")
    assert_equal(6, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal("か\u3099", @line_editor.line)
  end

  def test_ed_kill_line
    input_keys("\C-k")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('', @line_editor.line)
    input_keys('abc')
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-k")
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('abc', @line_editor.line)
    input_keys("\C-b\C-k")
    assert_equal(2, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('ab', @line_editor.line)
  end

  def test_em_kill_line
    input_keys("\C-u")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('', @line_editor.line)
    input_keys('abc')
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-u")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('', @line_editor.line)
    input_keys("abc\C-b\C-u")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('c', @line_editor.line)
    input_keys("\C-u")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('c', @line_editor.line)
  end

  def test_ed_move_to_beg
    input_keys('abd')
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(2, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys('c')
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-a")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys('012')
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('012abcd', @line_editor.line)
    input_keys("\C-a")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys('ABC')
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('ABC012abcd', @line_editor.line)
    input_keys("\C-f" * 10 + "\C-a")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys('a')
    assert_equal(1, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('aABC012abcd', @line_editor.line)
  end

  def test_ed_move_to_end
    input_keys('abd')
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(2, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys('c')
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-e")
    assert_equal(4, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys('012')
    assert_equal(7, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('abcd012', @line_editor.line)
    input_keys("\C-e")
    assert_equal(7, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys('ABC')
    assert_equal(10, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('abcd012ABC', @line_editor.line)
    input_keys("\C-b" * 10 + "\C-e")
    assert_equal(10, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys('a')
    assert_equal(11, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('abcd012ABCa', @line_editor.line)
  end

  def test_em_delete_or_list
    input_keys('ab')
    assert_equal(2, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-a")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-d")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('b', @line_editor.line)
  end

  def test_em_delete_or_list_for_mbchar
    input_keys('かき')
    assert_equal(6, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-a")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-d")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('き', @line_editor.line)
  end

  def test_em_delete_or_list_for_mbchar_by_plural_code_points
    input_keys("か\u3099き\u3099")
    assert_equal(12, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-a")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-d")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal("き\u3099", @line_editor.line)
  end

  def test_ed_clear_screen
    refute(@line_editor.instance_variable_get(:@cleared))
    input_keys("\C-l")
    assert(@line_editor.instance_variable_get(:@cleared))
  end

  def test_ed_clear_screen_with_inputed
    input_keys("abc\C-b")
    refute(@line_editor.instance_variable_get(:@cleared))
    assert_equal(2, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-l")
    assert(@line_editor.instance_variable_get(:@cleared))
    assert_equal(2, @line_editor.instance_variable_get(:@byte_pointer))
  end

  def test_em_next_word
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("abc def{bbb}ccc\C-a\M-F")
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-F")
    assert_equal(7, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-F")
    assert_equal(11, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-F")
    assert_equal(15, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-F")
    assert_equal(15, @line_editor.instance_variable_get(:@byte_pointer))
  end

  def test_em_next_word_for_mbchar
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("あいう かきく{さしす}たちつ\C-a\M-F")
    assert_equal(9, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-F")
    assert_equal(19, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-F")
    assert_equal(29, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-F")
    assert_equal(39, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-F")
    assert_equal(39, @line_editor.instance_variable_get(:@byte_pointer))
  end

  def test_em_next_word_for_mbchar_by_plural_code_points
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("あいう か\u3099き\u3099く\u3099{さしす}たちつ\C-a\M-F")
    assert_equal(9, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-F")
    assert_equal(28, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-F")
    assert_equal(38, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-F")
    assert_equal(48, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-F")
    assert_equal(48, @line_editor.instance_variable_get(:@byte_pointer))
  end

  def test_em_prev_word
    input_keys("abc def{bbb}ccc")
    assert_equal(15, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-B")
    assert_equal(12, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-B")
    assert_equal(8, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-B")
    assert_equal(4, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-B")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-B")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
  end

  def test_em_prev_word_for_mbchar
    input_keys("あいう かきく{さしす}たちつ")
    assert_equal(39, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-B")
    assert_equal(30, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-B")
    assert_equal(20, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-B")
    assert_equal(10, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-B")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-B")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
  end

  def test_em_prev_word_for_mbchar_by_plural_code_points
    input_keys("あいう か\u3099き\u3099く\u3099{さしす}たちつ")
    assert_equal(48, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-B")
    assert_equal(39, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-B")
    assert_equal(29, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-B")
    assert_equal(10, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-B")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-B")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
  end

  def test_em_delete_next_word
    input_keys("abc def{bbb}ccc\C-a")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-d")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal(' def{bbb}ccc', @line_editor.line)
    input_keys("\M-d")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('{bbb}ccc', @line_editor.line)
    input_keys("\M-d")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('}ccc', @line_editor.line)
    input_keys("\M-d")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('', @line_editor.line)
  end

  def test_em_delete_next_word_for_mbchar
    input_keys("あいう かきく{さしす}たちつ\C-a")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-d")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal(' かきく{さしす}たちつ', @line_editor.line)
    input_keys("\M-d")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('{さしす}たちつ', @line_editor.line)
    input_keys("\M-d")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('}たちつ', @line_editor.line)
    input_keys("\M-d")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('', @line_editor.line)
  end

  def test_em_delete_next_word_for_mbchar_by_plural_code_points
    input_keys("あいう か\u3099き\u3099く\u3099{さしす}たちつ\C-a")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-d")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal(" か\u3099き\u3099く\u3099{さしす}たちつ", @line_editor.line)
    input_keys("\M-d")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('{さしす}たちつ', @line_editor.line)
    input_keys("\M-d")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('}たちつ', @line_editor.line)
    input_keys("\M-d")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('', @line_editor.line)
  end

  def test_ed_delete_prev_word
    input_keys('abc def{bbb}ccc')
    assert_equal(15, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-\C-H")
    assert_equal(12, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('abc def{bbb}', @line_editor.line)
    input_keys("\M-\C-H")
    assert_equal(8, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('abc def{', @line_editor.line)
    input_keys("\M-\C-H")
    assert_equal(4, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('abc ', @line_editor.line)
    input_keys("\M-\C-H")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('', @line_editor.line)
  end

  def test_ed_delete_prev_word_for_mbchar
    input_keys('あいう かきく{さしす}たちつ')
    assert_equal(39, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-\C-H")
    assert_equal(30, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('あいう かきく{さしす}', @line_editor.line)
    input_keys("\M-\C-H")
    assert_equal(20, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('あいう かきく{', @line_editor.line)
    input_keys("\M-\C-H")
    assert_equal(10, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('あいう ', @line_editor.line)
    input_keys("\M-\C-H")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('', @line_editor.line)
  end

  def test_ed_delete_prev_word_for_mbchar_by_plural_code_points
    input_keys("あいう か\u3099き\u3099く\u3099{さしす}たちつ")
    assert_equal(48, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\M-\C-H")
    assert_equal(39, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal("あいう か\u3099き\u3099く\u3099{さしす}", @line_editor.line)
    input_keys("\M-\C-H")
    assert_equal(29, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal("あいう か\u3099き\u3099く\u3099{", @line_editor.line)
    input_keys("\M-\C-H")
    assert_equal(10, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('あいう ', @line_editor.line)
    input_keys("\M-\C-H")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('', @line_editor.line)
  end

  def test_ed_transpose_chars
    input_keys("abc\C-a")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    #input_keys("\C-t")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('abc', @line_editor.line)
    input_keys("\C-f\C-t")
    assert_equal(2, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('bac', @line_editor.line)
    input_keys("\C-t")
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('bca', @line_editor.line)
    input_keys("\C-t")
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('bac', @line_editor.line)
  end

  def test_ed_transpose_chars_for_mbchar
    input_keys("あかさ\C-a")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-t")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('あかさ', @line_editor.line)
    input_keys("\C-f\C-t")
    assert_equal(6, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('かあさ', @line_editor.line)
    input_keys("\C-t")
    assert_equal(9, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('かさあ', @line_editor.line)
    input_keys("\C-t")
    assert_equal(9, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('かあさ', @line_editor.line)
  end

  def test_ed_transpose_chars_for_mbchar_by_plural_code_points
    input_keys("あか\u3099さ\C-a")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-t")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal("あか\u3099さ", @line_editor.line)
    input_keys("\C-f\C-t")
    assert_equal(9, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal("か\u3099あさ", @line_editor.line)
    input_keys("\C-t")
    assert_equal(12, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal("か\u3099さあ", @line_editor.line)
    input_keys("\C-t")
    assert_equal(12, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal("か\u3099あさ", @line_editor.line)
  end

  def test_ed_digit
    input_keys('0123')
    assert_equal(4, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('0123', @line_editor.line)
  end

  def test_ed_next_and_prev_char
    input_keys('abc')
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(2, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(1, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-f")
    assert_equal(1, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-f")
    assert_equal(2, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-f")
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-f")
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
  end

  def test_ed_next_and_prev_char_for_mbchar
    input_keys('あいう')
    assert_equal(9, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(6, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-f")
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-f")
    assert_equal(6, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-f")
    assert_equal(9, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-f")
    assert_equal(9, @line_editor.instance_variable_get(:@byte_pointer))
  end

  def test_ed_next_and_prev_char_for_mbchar_by_plural_code_points
    input_keys("か\u3099き\u3099く\u3099")
    assert_equal(18, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(12, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(6, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-b")
    assert_equal(0, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-f")
    assert_equal(6, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-f")
    assert_equal(12, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-f")
    assert_equal(18, @line_editor.instance_variable_get(:@byte_pointer))
    input_keys("\C-f")
    assert_equal(18, @line_editor.instance_variable_get(:@byte_pointer))
  end

  def test_em_capitol_case
    input_keys("abc def{bbb}ccc\C-a\M-c")
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('Abc def{bbb}ccc', @line_editor.line)
    input_keys("\M-c")
    assert_equal(7, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('Abc Def{bbb}ccc', @line_editor.line)
    input_keys("\M-c")
    assert_equal(11, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('Abc Def{Bbb}ccc', @line_editor.line)
    input_keys("\M-c")
    assert_equal(15, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('Abc Def{Bbb}Ccc', @line_editor.line)
  end

  def test_em_capitol_case_with_complex_example
    input_keys("{}#*    AaA!!!cCc   \C-a\M-c")
    assert_equal(11, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('{}#*    Aaa!!!cCc   ', @line_editor.line)
    input_keys("\M-c")
    assert_equal(17, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('{}#*    Aaa!!!Ccc   ', @line_editor.line)
    input_keys("\M-c")
    assert_equal(20, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('{}#*    Aaa!!!Ccc   ', @line_editor.line)
  end

  def test_em_lower_case
    input_keys("AbC def{bBb}CCC\C-a\M-l")
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('abc def{bBb}CCC', @line_editor.line)
    input_keys("\M-l")
    assert_equal(7, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('abc def{bBb}CCC', @line_editor.line)
    input_keys("\M-l")
    assert_equal(11, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('abc def{bbb}CCC', @line_editor.line)
    input_keys("\M-l")
    assert_equal(15, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('abc def{bbb}ccc', @line_editor.line)
  end

  def test_em_lower_case_with_complex_example
    input_keys("{}#*    AaA!!!cCc   \C-a\M-l")
    assert_equal(11, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('{}#*    aaa!!!cCc   ', @line_editor.line)
    input_keys("\M-l")
    assert_equal(17, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('{}#*    aaa!!!ccc   ', @line_editor.line)
    input_keys("\M-l")
    assert_equal(20, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('{}#*    aaa!!!ccc   ', @line_editor.line)
  end

  def test_em_upper_case
    input_keys("AbC def{bBb}CCC\C-a\M-u")
    assert_equal(3, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('ABC def{bBb}CCC', @line_editor.line)
    input_keys("\M-u")
    assert_equal(7, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('ABC DEF{bBb}CCC', @line_editor.line)
    input_keys("\M-u")
    assert_equal(11, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('ABC DEF{BBB}CCC', @line_editor.line)
    input_keys("\M-u")
    assert_equal(15, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('ABC DEF{BBB}CCC', @line_editor.line)
  end

  def test_em_upper_case_with_complex_example
    input_keys("{}#*    AaA!!!cCc   \C-a\M-u")
    assert_equal(11, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('{}#*    AAA!!!cCc   ', @line_editor.line)
    input_keys("\M-u")
    assert_equal(17, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('{}#*    AAA!!!CCC   ', @line_editor.line)
    input_keys("\M-u")
    assert_equal(20, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('{}#*    AAA!!!CCC   ', @line_editor.line)
  end

  def test_completion
    @line_editor.completion_proc = proc { |word|
      %w{
        foo_foo
        foo_bar
        foo_baz
        qux
      }
    }
    input_keys('fo')
    assert_equal(2, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('fo', @line_editor.line)
    input_keys("\C-i")
    assert_equal(4, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('foo_', @line_editor.line)
    input_keys("\C-i")
    assert_equal(4, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('foo_', @line_editor.line)
    input_keys("a\C-i")
    assert_equal(5, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('foo_a', @line_editor.line)
    input_keys("\C-hb\C-i")
    assert_equal(6, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('foo_ba', @line_editor.line)
  end

  def test_completion_in_middle_of_line
    @line_editor.completion_proc = proc { |word|
      %w{
        foo_foo
        foo_bar
        foo_baz
        qux
      }
    }
    input_keys('abcde fo ABCDE')
    assert_equal('abcde fo ABCDE', @line_editor.line)
    input_keys("\C-b" * 6 + "\C-i")
    assert_equal(10, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('abcde foo_ ABCDE', @line_editor.line)
    input_keys("\C-b" * 2 + "\C-i")
    assert_equal(10, @line_editor.instance_variable_get(:@byte_pointer))
    assert_equal('abcde foo_o_ ABCDE', @line_editor.line)
  end
end
