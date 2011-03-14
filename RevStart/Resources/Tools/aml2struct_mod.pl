#!/usr/bin/perl

if (open(FILE, $ARGV[0]))
{
  binmode FILE;
  my ($buf, $data, $n, $len, $index, $str, $output_buffer, $byte_count);
  my $filesize = -s $ARGV[0];
  my $should_save = $ARGV[1];

  while (($n = read(FILE, $data, 4)) != 0)
  {
    $buf .= reverse($data);
    $len += $n;

    # Stupid little dot limiter.
    if (($filesize & $len) == 0)
    {
      print ".";
    }
  }
  close (FILE);
  printf ("\n%d Bytes to convert to little-endian:\n\n", $len);
  
  my $byte_index  = 0;
  my $index	  = 0;
  my $fill_length = 0;

  if ($len)
  {
    $str .= "\t";
  }

  while ($index < ($len + 1))
  {
    if ($byte_index == 0)
    {
       $str .= "0x";
       $byte_count = ($len - $index);

       # Do we need to add leading characters?
       if ($byte_count > 0 && $byte_count < 4)
       {
         # Yes we do. Give me a pointer,
         $fill_length = (4 - $byte_count);
         # Inject the leading zero's.
         $str .= substr("000000", 0, ($fill_length * 2));
         # Fix byte index pointer.
         $byte_index += $fill_length;
       }
    }
    # Next byte,
    $byte_index++;
    $byte = ord(substr($buf, $index, 1));
    # Add byte value.
    $str .= sprintf("%02X", $byte);
    $index++;

    # Is this the last byte of this word?
    if ($byte_index == 4)
    {
      # Yes it is. Reset byte index.
      $byte_index = 0;

      if ($index < $len)
      {
        $str .= ", ";
      }

      if ($should_save)
      {
        $output_buffer .= $str;
      }
      else
      {
        print $str;
      }

      $str = "";

      if (($index % 32) == 0)
      {
        $str .= "\\\n\t";
      }
    }
  }
  if ($should_save)
  {
    open(DAT, ">$should_save") || die $!;
    print DAT $output_buffer;
    close(DAT);
  }
  else
  {
    print "\n";
  }
} 
else
{
  print
    "\naml2struct.pl v1.0 (c) 2009 by Master Chief\n".
    "\n".
    "Usage:\n".
    "  perl aml2struct.pl <input.aml file> [output.txt file]\n".
    "\n";
}
